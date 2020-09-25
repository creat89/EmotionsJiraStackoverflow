package mulan.evaluation;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import mulan.evaluation.measure.ExampleBasedBipartitionMeasureBase;

public class PredictedVSActual extends ExampleBasedBipartitionMeasureBase {
	
	private List<Integer> tpCounter = new ArrayList<Integer>();
	private List<Integer> actualCounter = new ArrayList<Integer>();
	private List<Integer> predictionCounter = new ArrayList<Integer>();
	private List<Integer> zeroCounter = new ArrayList<Integer>();
	
	public PredictedVSActual(int nLabels)
	{
		for(int j=0; j<nLabels; j++)
		{
			tpCounter.add(0);
			actualCounter.add(0);
			predictionCounter.add(0);	
		}
		zeroCounter.add(0);
	}
	
	@Override
    public String getName() {
        return "Predicted VS Actual";
    }

    @Override
    public double getIdealValue() {
        return 0;
    }
    
    public HashMap<String, List<Integer>> getConfusionVector()
    {
    	HashMap<String, List<Integer>> results = new HashMap<String, List<Integer>>();
    	results.put("ExactMatch", tpCounter);
		results.put("Actual", actualCounter);
		results.put("Prediction", predictionCounter);
		results.put("Zero", zeroCounter);
		return results;
    }

    @Override
    protected void updateBipartition(boolean[] bipartition, boolean[] truth) {
    	int zero=0;
        for (int i = 0; i < truth.length; i++)
        {
        	if(truth[i])
        		actualCounter.set(i, actualCounter.get(i)+1);
        	if(bipartition[i])
        	{	
        		zero=1;
        		predictionCounter.set(i, predictionCounter.get(i)+1);
        	}
            if (bipartition[i] == truth[i] && truth[i]) {
            	tpCounter.set(i, tpCounter.get(i)+1);
            }
        }
        if(zero==0)
        	zeroCounter.set(0, zeroCounter.get(0)+1);
    }
}
