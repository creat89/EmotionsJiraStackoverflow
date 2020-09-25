# encoding: utf-8
import getopt
import sys
import os
import subprocess
import re
import pprint
import functools
from py4j.java_gateway import JavaGateway, GatewayParameters
if sys.version_info >= (3, 4, 0):
	print=functools.partial(print,flush=True)
from bayes_opt import BayesianOptimization
#import pprint #Debug


def roundToNearestMultiple(number, multiple):
	if(number%multiple > multiple/2):
		return int(number + multiple - number%multiple)
	else:
		return int(number - number%multiple)

def optimization():
	optimized=BayesianOptimization(cross_validation, {'ngrams':(1,3), 'skipbigrams':(0,2), 'mini':(1,50), 'subset':(2,5)})
	optimized.maximize(init_points=25, n_iter=10, kappa=2)
	print(optimized.res['max'])

def cross_validation(ngrams,skipbigrams, mini, subset):
	params={}
	params['pathMulan']=pathHomer
	params['pathInput']=pathInput
	params['nameTrain']=nameTrain
	params['eval_type']="Develop"
	params['nameTest']=nameTrain
	params['extra']=extraFeatures
	params['ngrams']=roundToNearestMultiple(ngrams,1)
	params['skipbigrams']=roundToNearestMultiple(skipbigrams,1)
	if(mini<5.5):
		params['mini']=roundToNearestMultiple(mini,1)
	else:
		params['mini']=roundToNearestMultiple(mini,5)
	params['subset']=roundToNearestMultiple(subset,1)
	print(params)
	for cv in range(0,10):
		params['id']=cv
		perl="perl ./vectorizer_Mulan.perl -f -F Mulan -n %s -s %s -m %s -e %s -i %s -T %s %s %s" % (params['ngrams'], params['skipbigrams'], params['mini'], params['extra'], params['id'], params['nameTrain'], params['pathInput'], params['pathMulan'])
		#This command doesn't run in Windows
		#subprocess.run(perl, shell=True, check=True)
		os.system(perl)
	mulanLoader.createRakel(params['subset'])
	result=mulanLoader.optimization()
	print("\t")
	print(result)
	print("\n")
	return result

def train(process):
	params={}
	params['extra']=extraFeatures
	#----------------------------------------------LEMMA
	#NRC and NRC intensity
	if(modelDictName=="NRC_NRCIntensity_rakel_lemma"):
		params['ngrams']=3
		params['skipbigrams']=2
		params['mini']=5
		params['subset']=3
	elif(modelDictName=="NRC_OrtuNN_rakel_lemma"):	#It wasn't optimized, but we need less clusters than labels
		params['ngrams']=1
		params['skipbigrams']=2
		params['mini']=15
		params['subset']=5
	elif(modelDictName=="Sentic_OrtuNN_rakel_lemma"): #Temporal best
	 	params['ngrams']=1
	 	params['skipbigrams']=2
	 	params['mini']=1
	 	params['subset']=5
	elif(modelDictName=="NRC_SONN_rakel_lemma"):
	 	params['ngrams']=1
	 	params['skipbigrams']=1
	 	params['mini']=35
	 	params['subset']=5
	elif(modelDictName=="Sentic_SONN_rakel_lemma"):
	 	params['ngrams']=1
	 	params['skipbigrams']=0
	 	params['mini']=25
	 	params['subset']=5
	#----------------------------------------------NO LEMMA
	#NRC and NRC intensity
	elif(modelDictName=="NRC_NRCIntensity_rakel_no_lemma"):
		params['ngrams']=3
		params['skipbigrams']=1
		params['mini']=15
		params['subset']=2
	elif(modelDictName=="NRC_OrtuNN_rakel_no_lemma"):	#It wasn't optimized, but we need less clusters than labels
		params['ngrams']=3
		params['skipbigrams']=0
		params['mini']=1
		params['subset']=5
	elif(modelDictName=="Sentic_OrtuNN_rakel_no_lemma"):
		params['ngrams']=1
		params['skipbigrams']=2
		params['mini']=1
		params['subset']=5
	elif(modelDictName=="NRC_SONN_rakel_no_lemma"):
		params['ngrams']=3
		params['skipbigrams']=1
		params['mini']=40
		params['subset']=4
	elif(modelDictName=="Sentic_SONN_rakel_no_lemma"):
		params['ngrams']=1
		params['skipbigrams']=1
		params['mini']=20
		params['subset']=5
	else:
		print >> sys.stderr, "uknow parameters"
		sys.exit(1)

	if(process=="train_cv"):
		cross_validation(params['ngrams'],params['skipbigrams'], params['min'], params['subset'])
	elif(process=="train"):
		params['pathMulan']=pathHomer
		params['pathInput']=pathInput
		params['nameTrain']=nameTrain
		params['extra']=extraFeatures
		params['modelDictPath']=modelDictPath
		params['modelDictName']=modelDictName
		params['id']='all'
		perl="perl ./vectorizer_Mulan.perl -f -F Mulan -n %s -s %s -m %s -e %s -i %s -T %s -M %s -p %s %s %s" % (params['ngrams'], params['skipbigrams'], params['mini'], params['extra'], params['id'], params['nameTrain'], params['modelDictPath'], params['modelDictName'], params['pathInput'], params['pathMulan'])
		os.system(perl)
		name=modelDictPath + "/" + modelDictName + ".mulan"
		mulanLoader.createRakel(params['subset'])
		mulanLoader.train(name)
	else:
		print >> sys.stderr, "Unknown process call"
		sys.exit(1)

def test():
	params={}
	params['pathMulan']=pathHomer
	params['pathInput']=pathInput
	params['eval_type']="Test"
	params['nameTest']=nameTest
	params['modelDictPath']=modelDictPath
	params['modelDictName']=modelDictName
	params['id']='all'
	perl="perl ./vectorizer_Mulan.perl -f -F Mulan -i %s -t %s -M %s -p %s %s %s" % (params['id'], params['nameTest'], params['modelDictPath'], params['modelDictName'], params['pathInput'], params['pathMulan'])
	print(perl)
	os.system(perl)
	name=modelDictPath + "/" + modelDictName + ".mulan"
	result=mulanLoader.predictWithEval("Rakel", name)
	print(result)
	print("\n")

def predict():
	params={}
	params['pathMulan']=pathHomer
	params['pathInput']=pathInput
	params['eval_type']="Test"
	params['nameTest']=nameTest
	params['modelDictPath']=modelDictPath
	params['modelDictName']=modelDictName
	params['id']='all'
	perl="perl ./vectorizer_Mulan.perl -f -F Mulan -i %s -t %s -M %s -p %s %s %s" % (params['id'], params['nameTest'], params['modelDictPath'], params['modelDictName'], params['pathInput'], params['pathMulan'])
	print(perl)
	os.system(perl)
	name=modelDictPath + "/" + modelDictName + ".mulan"
	outputFile=outputPath + "/" + nameTest + "-" + modelDictName +".lacd"
	mulanLoader.predict("Rakel", name, outputFile)
	print("\n")


options, remainder = getopt.getopt(sys.argv[1:], 'o:T:t:e:M:m:')
nameTrain=""
nameTest=""
operation=""
for opt, arg in options:
	if(opt=="-o"):
		if(arg=="train" or arg=="test" or arg=="opt" or arg=="train_cv" or arg=="predict"):
			operation=arg
		else:
			print >> sys.stderr, "Unknown type of operation"
			sys.exit(1)
	if(opt=="-T"):
		nameTrain=arg
		print(nameTrain)
	if(opt=="-t"):
		nameTest=arg
	if(opt=="-e"):
		extraFeatures=int(arg)
	if(opt=="-m"):
		modelDictPath=arg
		modelDictPath=re.sub("/cygdrive/d","D:/", modelDictPath)
	if(opt=="-M"):
		modelDictName=arg


pathInput=remainder[0]
pathHomer=remainder[1]

gateway = JavaGateway(gateway_parameters=GatewayParameters(port=25341))
mulanLoader = gateway.entry_point.getMulanLoader()
pathInput=re.sub("/cygdrive/d","D:/", pathInput)
pathHomer=re.sub("/cygdrive/d","D:/", pathHomer)
mulanLoader.setPath(pathHomer)

if(operation=="opt"):
	if(nameTrain==""):
		print >> sys.stderr, "Please specify a name for the train"
		sys.exit(1)
	mulanLoader.setTrainDataSet(nameTrain)
	sys.stdout=open(remainder[2],"w")
	sys.stdout.flush()
	optimization()
	sys.stdout.close()
elif(operation=="train"):
	if(nameTrain==""):
		print >> sys.stderr, "Please specify a name for the train"
		sys.exit(1)
	if(modelDictPath==""):
		print >> sys.stderr, "Please specify a path for the train"
		sys.exit(1)
	if(modelDictName==""):
		print >> sys.stderr, "Please specify a name for the train"
		sys.exit(1)
	mulanLoader.setTrainDataSet(nameTrain)
	train("train")
elif(operation=="test"):
	if(modelDictPath==""):
		print >> sys.stderr, "Please specify a path for the train"
		sys.exit(1)
	if(modelDictName==""):
		print >> sys.stderr, "Please specify a name for the train"
		sys.exit(1)
	mulanLoader.setTestDataSet(nameTest)
	test()
elif(operation=="predict"):
	if(modelDictPath==""):
		print >> sys.stderr, "Please specify a path for the train"
		sys.exit(1)
	if(modelDictName==""):
		print >> sys.stderr, "Please specify a name for the train"
		sys.exit(1)
	outputPath=remainder[2]
	outputPath=re.sub("/cygdrive/d","D:/", outputPath)
	mulanLoader.setTestDataSet(nameTest)
	predict()
elif(operation=="train_cv"):
	if(nameTrain==""):
		print >> sys.stderr, "Please specify a name for the train"
		sys.exit(1)
	mulanLoader.setTrainDataSet(nameTrain)
	mulanLoader.setTestDataSet(nameTrain)
	train("train_cv")
else:
	print >> sys.stderr, "unknown things"
	sys.exit(1)
