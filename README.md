# Welcome

In this repository you will find the code that was used in the Emotion Classifier presented in the article _Classifying emotions in Stack Overflow and JIRA using a multi-label approach_.

```
@article{CABRERADIEGO2020105633,
title = "Classifying emotions in Stack Overflow and JIRA using a multi-label approach",
journal = "Knowledge-Based Systems",
volume = "195",
pages = "105633",
year = "2020",
issn = "0950-7051",
doi = "https://doi.org/10.1016/j.knosys.2020.105633",
author = "Luis Adrián Cabrera-Diego and Nik Bessis and Ioannis Korkontzelos",
}
```

To run the code there are two steps:

1. First, run the Java code, found in the the folder _MultiLabelJava_. You will need to install Mulan: http://mulan.sourceforge.net/. As well, in order to run, you will need to install _py4j_ a library that allows to call Java from Python code (this has been set as a POM requirement).

2. The second part is found in the directory _Emotion_Analysis_. There you will find the Bash files used to run the code. These files will call the Python files which will process the data to replicate the experiments. The parameters described in the article are written in the Python files. It should be noted that the Python files call a Perl script that vectorizes the data and generates an input suitable for Mulan.

The basic syntax for optimizing the files are:
```
  python3 experiments_Homer.py -o opt -T [DATASET_NAME] -e [NUMBER_EXTRA_FEATURES] [INPUT_DATA] [MULAN_DATA_STORAGE] [OUTPUT_FILE_FROM_OPTIMIZATION]
```
For training:
```
python3 experiments_Homer.py -o train -T [DATASET_NAME] -e [NUMBER_EXTRA_FEATURES] -m [MODEL_SAVING_PATH] -M [MODEL_NAME] [INPUT_DATA] [MULAN_DATA_STORAGE]
```
For testing:
```
python3 experiments_Homer.py -o test -t [DATASET_NAME] -m [MODEL_SAVING_PATH] -M [MODEL_NAME] [INPUT_DATA] [MULAN_DATA_STORAGE]
```

For predicting:
```
python3 experiments_Homer.py -o predict -t [DATASET_NAME] -m [MODEL_SAVING_PATH] -M [MODEL_NAME] [INPUT_DATA] [MULAN_DATA_STORAGE] [OUTPUT_PREDICTIONS_FILE]
```

## Data

We have included the split of the data used in these experiments. In this case, we split the original datasets into train/dev and testing using a stratified approach. During the optimization, the program will use a split done using a 10-fold-cross-validation. During training, the system will use the full training dataset. The data is already in a random order for train and dev.

There are two formats, one used by our program and another used by EmoTxt.

If you make use of the data, please cite their respective authors, I have just split their corpora and processed for the experiments:

Jira Dataset (Called in the repository  OrtuNN):

```
@inproceedings{ortu2016emotional,
  title={The emotional side of software developers in JIRA},
  author={Ortu, Marco and Murgia, Alessandro and Destefanis, Giuseppe and Tourani, Parastou and Tonelli, Roberto and Marchesi, Michele and Adams, Bram},
  booktitle={2016 IEEE/ACM 13th Working Conference on Mining Software Repositories (MSR)},
  pages={480--483},
  year={2016},
  organization={IEEE}
}
```

StackOverflow Dataset:

```
@inproceedings{novielli2018gold,
  title={A gold standard for emotion annotation in stack overflow},
  author={Novielli, Nicole and Calefato, Fabio and Lanubile, Filippo},
  booktitle={2018 IEEE/ACM 15th International Conference on Mining Software Repositories (MSR)},
  pages={14--17},
  year={2018},
  organization={IEEE}
}
```

## Notes

The code needs to be cleaned, we will work on this aspect as soon as possible. But the code should run by updating the corresponding paths.

Currently, the data is already processed. However, We will upload in the future the code for processing the data and getting the numeric values. And also the indixes used for splitting the corpora.

In all the cases, if you have any issue or problem running the code, don't hesitate in opening a Github issue. We will answer as soon as possible.
