# encoding: utf-8
import getopt
import sys
import os
import subprocess
import re
import functools
from py4j.java_gateway import JavaGateway, GatewayParameters
if sys.version_info >= (3, 4, 0):
	print=functools.partial(print,flush=True)
from bayes_opt import BayesianOptimization

def roundToNearestMultiple(number, multiple):
	if(number % multiple > multiple/2):
		return int(number + multiple - number%multiple)
	else:
		return int(number - number%multiple)

def optimization():
	optimized=BayesianOptimization(cross_validation, {'ngrams':(1,3), 'skipbigrams':(0,2), 'mini':(1,50), 'lr':(0.001,0.5), 'epochs':(10,100)})
	optimized.maximize(init_points=25, n_iter=10, kappa=2)
	print(optimized.res['max'])

def cross_validation(ngrams,skipbigrams, mini, lr, epochs):
	params={}
	params['pathMulan']=pathHomer
	params['pathInput']=pathInput
	params['nameTrain']=nameTrain
	params['eval_type']="Develop"
	params['nameTest']=nameTrain
	params['extra']=48
	params['decayCost']=0.00001 #The default in Mulan as in the original paper they do not test this parameter
	params['lr']=lr #The default in Mulan
	params['ngrams']=roundToNearestMultiple(ngrams,1)
	params['skipbigrams']=roundToNearestMultiple(skipbigrams,1)
	if(mini<5.5):
		params['mini']=roundToNearestMultiple(mini,1)
	else:
		params['mini']=roundToNearestMultiple(mini,5)
	params['epochs']=roundToNearestMultiple(epochs,10)
	print(params)
	for cv in range(0,10):
		params['id']=cv
		perl="perl ./vectorizer_Mulan.perl -f -F Mulan -n %s -s %s -m %s -e %s -i %s -T %s %s %s" % (params['ngrams'], params['skipbigrams'], params['mini'], params['extra'], params['id'], params['nameTrain'], params['pathInput'], params['pathMulan'])
		#This command doesn't run in Windows
		#subprocess.run(perl, shell=True, check=True)
		os.system(perl)
	mulanLoader.createBPMLL(params['lr'], params['decayCost'], params['epoch'])
	result=mulanLoader.optimization()
	print("\t")
	print(result)
	print("\n")
	return result

def trainAndTest(ngrams,skipbigrams, mini, c):
	params={}


options, remainder = getopt.getopt(sys.argv[1:], 'o:T:t:')
nameTrain=""
nameTest=""
operation=""
for opt, arg in options:
	if(opt=="-o"):
		if(arg=="trainTest" or arg=="opt" or arg=="trainCV"):
			operation=arg
		else:
			print >> sys.stderr, "Unknown type of operation"
			sys.exit(1)
	if(opt=="-T"):
			nameTrain=arg
			print(nameTrain)
	if(opt=="-t"):
			nameTest=arg


if(nameTrain==""):
	print >> sys.stderr, "Please specify a name for the train"
	sys.exit(1)

pathInput=remainder[0]
pathHomer=remainder[1]

gateway = JavaGateway(gateway_parameters=GatewayParameters(port=25335))
mulanLoader = gateway.entry_point.getMulanLoader()
pathInput=re.sub("/cygdrive/d","D:/", pathInput)
pathHomer=re.sub("/cygdrive/d","D:/", pathHomer)
mulanLoader.setPath(pathHomer)

if(operation=="opt"):
	mulanLoader.setTrainDataSet(nameTrain)
	sys.stdout=open(remainder[2],"w")
	sys.stdout.flush()
	optimization()
	sys.stdout.close()
else:
	exit(1)
