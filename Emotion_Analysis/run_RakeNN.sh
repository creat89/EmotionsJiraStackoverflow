#Rakel Optimization

#perl ./files_organizer_2.perl -P -n OrtuNN -f basttext /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/
#perl ./files_organizer_2.perl -P -n OrtuNN -f basttext /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/
#perl ./files_organizer_2.perl -P -n SOEmotionsNN -f basttext /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/Sentic/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/
#perl ./files_organizer_2.perl -P -n SOEmotionsNN -f basttext /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/Sentic/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/

#python3 experiments_Rakel.py -o opt -T OrtuNN -e 48 /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/No_Lemma/optimization_Rakel_48_NRC_OrtuNN_no_lemma.txt
#python3 experiments_Rakel.py -o opt -T OrtuNN -e 48 /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/Lemma/optimization_Rakel_48_NRC_OrtuNN_lemma.txt

#python3 experiments_Rakel.py -o opt -T OrtuNN -e 53 /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/Sentic/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/Sentic/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/Sentic/No_Lemma/optimization_Rakel_48_Sentic_OrtuNN_no_lemma.txt
#python3 experiments_Rakel.py -o opt -T OrtuNN -e 53 /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/Sentic/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/Sentic/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/Sentic/Lemma/optimization_Rakel_48_Sentic_OrtuNN_lemma.txt

python3 experiments_Rakel.py -o opt -T SOEmotionsNN -e 53 /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/Sentic/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/Sentic/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/Sentic/Lemma/optimization_Rakel_53_Sentic_SONN_lemma.txt

#Rakel Training

#python3 experiments_Rakel.py -o train -T OrtuNN -e 48 -m /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Models/NoNeutral/No_Lemma/ -M NRC_NRCIntensity_rakel_no_lemma /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/No_Lemma/
#python3 experiments_Rakel.py -o train -T OrtuNN -e 48 -m /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Models/NoNeutral/Lemma/ -M NRC_NRCIntensity_rakel_lemma /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/Lemma/

#Rakel Testing

#python3 experiments_Rakel.py -o test -t OrtuNN -m /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Models/NoNeutral/No_Lemma/ -M NRC_NRCIntensity_rakel_no_lemma /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/No_Lemma/
#python3 experiments_Rakel.py -o test -t OrtuNN -m /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Models/NoNeutral/Lemma/ -M NRC_NRCIntensity_rakel_lemma /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/Lemma/

#python3 experiments_Rakel.py -o test -t SOEmotionsNN -m /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Models/NoNeutral/No_Lemma/ -M NRC_NRCIntensity_rakel_no_lemma /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/No_Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/No_Lemma/
#python3 experiments_Rakel.py -o test -t SOEmotionsNN -m /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Models/NoNeutral/Lemma/ -M NRC_NRCIntensity_rakel_lemma /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/BastText/NoNeutral/NRC_NRCIntensity/Lemma/ /cygdrive/d/Sentiment_Analysis/Emotion_Adrian/Mulan/NoNeutral/NRC_NRCIntensity/Lemma/