package mulan;

import java.io.BufferedWriter;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.nio.charset.Charset;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;

import mulan.classifier.InvalidDataException;
import mulan.classifier.MultiLabelLearner;
import mulan.classifier.MultiLabelOutput;
import mulan.classifier.meta.HOMER;
import mulan.classifier.meta.HierarchyBuilder;
import mulan.classifier.meta.RAkEL;
import mulan.classifier.neural.BPMLL;
import mulan.classifier.transformation.BinaryRelevance;
import mulan.data.InvalidDataFormatException;
import mulan.data.MultiLabelInstances;
import mulan.evaluation.Evaluation;
import mulan.evaluation.Evaluator;
import mulan.evaluation.PredictedVSActual;
import mulan.evaluation.SubSet01Loss;
import mulan.evaluation.measure.HammingLoss;
import mulan.evaluation.measure.MacroFMeasure;
import mulan.evaluation.measure.Measure;
import mulan.evaluation.measure.MicroFMeasure;
import weka.classifiers.trees.J48;
import weka.core.Instance;
import weka.core.SerializationHelper;

public class MulanLoader
{
	
	private String path="";
	private String trainDataSet = "";
	private String testDataSet = "";
	private int counterIteration=1;
	
	private int numSubset;
	private int numClusters;
	
	private double lr;
	private double decayCost;
	private int epochs;
	
	private String typeClassifier="";
	
	
	public void setPath(String path)
	{
		this.path=path;
	}
	
	public void setTrainDataSet(String dataSet)
	{
		this.trainDataSet=dataSet;
	}
	
	public void setTestDataSet(String dataSet)
	{
		this.testDataSet=dataSet;
	}
	
	/**
	 * 
	 * @param lr Between 0 and 1
	 * @param decayCost Between 0 and 1
	 * @param epochs Between 1 and infinity, default 100
	 * @return
	 */
	public void createBPMLL(double lr, double decayCost, int epochs)
	{
		this.lr=lr;
		this.decayCost=decayCost;
		this.epochs=epochs;
		this.typeClassifier="BPMLL";
	}
	
	public BPMLL createBPMLL()
	{
		BPMLL classifier = new BPMLL();
		classifier.setLearningRate(lr);
		classifier.setWeightsDecayRegularization(decayCost);
		classifier.setTrainingEpochs(epochs);
		return classifier;
	}
	
	public void createHOMER(int numClusters)
	{
		this.numClusters=numClusters;
		this.typeClassifier="Homer";
	}
	
	public HOMER createHOMER()
	{
		//We're building a typical HOMER except for the number of clusters
		HOMER classifier = new HOMER(new BinaryRelevance(new J48()), numClusters, HierarchyBuilder.Method.BalancedClustering);
		return classifier;
	}
	
	/**
	 * 
	 * @param numSubset Cannot be greater or equal to the number of labels to classify
	 * @return A RAkeL model
	 */
	public void createRakel(int numSubset)
	{
		this.numSubset=numSubset;
		this.typeClassifier="Rakel";
	}
	
	private RAkEL createRakel()
	{
		RAkEL classifier = new RAkEL();
		classifier.setSizeOfSubset(numSubset);
		return classifier;
	}
	
	public void train(String modelOutput)
	{
		MultiLabelLearner classifier=classifierBuilder();
		Path trainTextPath = Paths.get(path+"\\Train\\Train_"+ trainDataSet + "_all_Mulan.txt");
		Path trainXMLPath = Paths.get(path+"\\Train\\Train_"+ trainDataSet + "_all_Mulan.xml");         
		MultiLabelInstances datasetTraining;
		try {
			System.err.println("The model is training");
			datasetTraining = new MultiLabelInstances(trainTextPath.toString(), trainXMLPath.toString());
			classifier.build(datasetTraining);
			System.err.println("Training has finished, model is being stored");
			SerializationHelper.write(modelOutput, classifier);
			System.err.println("The model has been stored");
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        
		
	}
	
	public void predict(String classifierType, String modelInput, String outputFile)
	{
		try {
			MultiLabelLearner classifier=modelLoader(classifierType, modelInput);
			Path testTextPath = Paths.get(path+"\\Test\\Test_"+ testDataSet + "_all_Mulan.txt");
			Path testXMLPath = Paths.get(path+"\\Test\\Test_"+ testDataSet + "_all_Mulan.xml");
			MultiLabelInstances datasetTesting = new MultiLabelInstances(testTextPath.toString(), testXMLPath.toString());
			
			Path outputPath = Paths.get(outputFile);
			Writer output = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(outputPath.toFile()),
				     Charset.forName("UTF-8").newEncoder()));
			
			boolean[] preOutput;
			for(Instance instance : datasetTesting.getDataSet())
			{
				preOutput = classifier.makePrediction(instance).getBipartition();
				for(int i=0; i<datasetTesting.getNumLabels(); i++)
				{
					if(preOutput[i]==true)
						output.write("1");
					else
						output.write("0");
					if(i<datasetTesting.getNumLabels()-1)
						output.write("\t");
				}
				output.write("\n");
			}
			output.close();
			
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	
	public double predictWithEval(String classifierType, String modelInput)
	{
		try {
			MultiLabelLearner classifier=modelLoader(classifierType, modelInput);
			Path testTextPath = Paths.get(path+"\\Test\\Test_"+ testDataSet + "_all_Mulan.txt");
			Path testXMLPath = Paths.get(path+"\\Test\\Test_"+ testDataSet + "_all_Mulan.xml");
			MultiLabelInstances datasetTesting = new MultiLabelInstances(testTextPath.toString(), testXMLPath.toString());
            
			Evaluator eval = new Evaluator();
			List<Measure> evalMeasures = new ArrayList<Measure>();
            MacroFMeasure macroF = new MacroFMeasure(datasetTesting.getNumLabels());
            MicroFMeasure microF = new MicroFMeasure(datasetTesting.getNumLabels());
            HammingLoss hammingLoss = new HammingLoss();
            SubSet01Loss subset01 = new SubSet01Loss();
            PredictedVSActual predictedVSActual = new PredictedVSActual(datasetTesting.getNumLabels());
            
            evalMeasures.add(macroF);
            evalMeasures.add(microF);
            evalMeasures.add(hammingLoss);
            evalMeasures.add(subset01);
            evalMeasures.add(predictedVSActual);
            
            Evaluation results = eval.evaluate(classifier, datasetTesting, evalMeasures);
			
            double resultMacroF = results.getMeasures().get(0).getValue();
            double resultMicroF = results.getMeasures().get(1).getValue();
            double resultHamming = results.getMeasures().get(2).getValue();
            double resultSubset = results.getMeasures().get(3).getValue();
            HashMap<String, List<Integer>> resultsPredictedVsActual = predictedVSActual.getConfusionVector();
            
            System.err.println("\n+\t\tMacroF: " + resultMacroF);
            System.err.println("\n+\t\tMicroF: " + resultMicroF);
            System.err.println("\n+\t\tH: " + resultHamming);
            System.err.println("\n+\t\tS01: " + resultSubset);
            System.err.println("\n+\t\tActual: "+ resultsPredictedVsActual.get("Actual"));
			System.err.println("\n+\t\tExactMatch: "+ resultsPredictedVsActual.get("ExactMatch"));
			System.err.println("\n+\t\tPrediction: "+ resultsPredictedVsActual.get("Prediction"));
			System.err.println("\n+\t\tZero: "+ resultsPredictedVsActual.get("Zero"));
            
            return resultMacroF;
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return Double.NaN;
	}
	
	public double optimization() throws InvalidDataException, Exception
	{
		System.err.println("Optimization Iteration: "+ counterIteration++);
		
		        
        //AdrianCSVRecordReader2 trainTextReader;
        Path trainTextPath;
        Path trainXMLPath;
        
        Path testTextPath;
        Path testXMLPath;
        
        List<Double> fscores  = new ArrayList<Double>();
        
        MultiLabelInstances datasetTraining;
        
        MultiLabelInstances datasetTesting;
        
        Evaluator eval;
        
        List<Measure> evalMeasures;
        
        double resultMacroF;
        
        
        MultiLabelLearner classifier=null;
        
        for(int i=0; i<10; i++)
        {
        	classifier=classifierBuilder();
        	System.err.println("\tFold:"+i);
        	//Training
            trainTextPath = Paths.get(path+"\\Train\\Train_"+ trainDataSet + "_"+ i +"_Mulan.txt");
            trainXMLPath = Paths.get(path+"\\Train\\Train_"+ trainDataSet + "_"+ i +"_Mulan.xml");         
            datasetTraining = new MultiLabelInstances(trainTextPath.toString(), trainXMLPath.toString());
            
			classifier.build(datasetTraining);
            
            //Testing
            testTextPath = Paths.get(path+"\\Develop\\Develop_"+ trainDataSet + "_"+ i +"_Mulan.txt");
            testXMLPath = Paths.get(path+"\\Develop\\Develop_"+ trainDataSet + "_"+ i +"_Mulan.xml");
            datasetTesting = new MultiLabelInstances(testTextPath.toString(), testXMLPath.toString());
            
            eval = new Evaluator();
            evalMeasures = new ArrayList<Measure>();
            
            MacroFMeasure macroF = new MacroFMeasure(datasetTraining.getNumLabels());
            
            evalMeasures.add(macroF);
            
            Evaluation results = eval.evaluate(classifier, datasetTesting, evalMeasures);
			
            resultMacroF = results.getMeasures().get(0).getValue();
            
            System.err.println("\n+\t\tMacroF: " + resultMacroF);
            
            fscores.add(resultMacroF);
        }
        double average=fscores.stream().mapToDouble(f->f).average().getAsDouble();
        double median=median(fscores);
        System.err.println("\t\tAverage: "+ average + "\tMedian: " + median);
        return(Math.min(average,median));
	}
	
	private MultiLabelLearner modelLoader(String classifierType, String modelInput) throws Exception
	{
		switch(classifierType)
		{
			case "Rakel":
				return (RAkEL) SerializationHelper.read(modelInput); 
			case "Homer":
				return (HOMER) SerializationHelper.read(modelInput); 
			case "BPMLL":
				return (BPMLL) SerializationHelper.read(modelInput); 
			default:
				System.err.println("The model is not supported :"+ classifierType);
				System.exit(1);
		}
		return null;
	}
	
	private MultiLabelLearner classifierBuilder()
	{
		switch(typeClassifier)
		{
			case "Rakel":
				return createRakel();
			case "Homer":
				return createHOMER();
			case "BPMLL":
				return createBPMLL();
			default:
				System.err.println("No classifier found:"+ typeClassifier);
				System.exit(1);
		}
		return null;
	}
	
	private double median (List<Double> values)
	{
		int middle = values.size()/2;
		Collections.sort(values);
        if (values.size() % 2 == 1) {
            return values.get(middle);
        } else {
           return (values.get(middle-1) + values.get(middle)) / 2.0;
        }
	}
	
	
	public static void main(String[] args) throws Exception
	{
		MulanLoader dataLoader = new MulanLoader();
		dataLoader.setPath("D:\\Sentiment_Analysis\\Emotion_Adrian\\Homer\\No_Lemma\\");
		dataLoader.setTrainDataSet("Ortu");
		dataLoader.createRakel(3);
		dataLoader.optimization();
    }
}
