proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;

LIBNAME myxls XLSX "C:\Users\HP\Documents\Fraud_Detection_Project\Fraud_Results.xlsx";

DATA myxls.ConfusionMatrix;
    SET LogitOut;
RUN;

DATA myxls.Metrics;
    SET Metrics;
RUN;

DATA myxls.Features;
    SET fraud_data_features;
RUN;

LIBNAME myxls CLEAR;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;
proc import datafile="C:\Users\HP\Documents\Fraud_Detection_Project\credit_card.csv\creditcard.csv"
out=fraud_data
dbms=csv
replace;
getnames=yes;
run;

*========================================Data Cleaning=========================*;
DATA fraud_data_clean;
    SET fraud_data;
    IF Class = '1' THEN Fraud = 1;
    ELSE Fraud = 0;
    DROP Class;
RUN;

/* Check for missing values */
PROC MEANS DATA=fraud_data_clean N NMISS;
RUN;

/* Check class distribution */
PROC FREQ DATA=fraud_data_clean;
    TABLES Fraud / NOCUM NOPERCENT;
RUN;

*====================================Feature Engineering=========================*;
*==================Transaction Hour====================*;
DATA fraud_data_features;
    SET fraud_data_clean;
    Hour = MOD(Time/3600, 24);
RUN;
*==================Amount Buckets====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Amount < 50 THEN Amount_Bucket = 'Low';
    ELSE IF 50 <= Amount < 200 THEN Amount_Bucket = 'Medium';
    ELSE IF Amount >= 200 THEN Amount_Bucket = 'High';
RUN;
*==================Normalize Amount====================*;
PROC STANDARD DATA=fraud_data_features MEAN=0 STD=1 OUT=fraud_data_norm;
    VAR Amount;
RUN;
*==================Frequency Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Time <= 86400 THEN Day1_Flag = 1; ELSE Day1_Flag = 0;
    IF Time <= 604800 THEN Week1_Flag = 1; ELSE Week1_Flag = 0;
RUN;
*==================Channel Flags====================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF MOD(_N_, 2) = 0 THEN Channel_Flag = 'Mobile';
    ELSE Channel_Flag = 'Web';
RUN;

*====================================Handling Class Imbalance=========================*;
DATA fraud_data_features;
    SET fraud_data_features;
    IF Fraud = 1 THEN FraudWeight = 100; /* emphasize fraud cases */
    ELSE FraudWeight = 1;
RUN;

*==========================================Modeling===================================*;
PROC LOGISTIC DATA=fraud_data_features;
    CLASS Fraud(ref='0') Amount_Bucket(ref='Low') Channel_Flag(ref='Web');
    MODEL Fraud(event='1') = V1-V28 Amount Hour Amount_Bucket Channel_Flag;
    WEIGHT FraudWeight;
    OUTPUT OUT=LogitOut PREDPROBS=INDIVIDUAL;
RUN;

/* Confusion matrix */
DATA LogitOut;
    SET LogitOut;
    IF IP_1 >= 0.5 THEN PredClass = 1;
    ELSE PredClass = 0;
RUN;

PROC FREQ DATA=LogitOut;
    TABLES Fraud*PredClass / NOCUM NOPERCENT;
RUN;

*======================================Visualization===================================*;
PROC SGPLOT DATA=fraud_data_clean;
    VBAR Fraud;
    TITLE "Fraud vs Non-Fraud Counts";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    HISTOGRAM Amount / GROUP=Fraud TRANSPARENCY=0.5;
    DENSITY Amount / GROUP=Fraud;
    TITLE "Distribution of Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    VBOX Amount / CATEGORY=Fraud;
    TITLE "Transaction Amounts by Fraud Status";
RUN;

PROC SGPLOT DATA=fraud_data_features;
    SCATTER X=Hour Y=Amount / GROUP=Fraud;
    TITLE "Transaction Hour vs Amount by Fraud Status";
RUN;

LIBNAME myxls XLSX "C:\Users\HP\Documents\Fraud_Detection_Project\Fraud_Results.xlsx";

DATA myxls.ConfusionMatrix;
    SET LogitOut;
RUN;

DATA myxls.Metrics;
    SET Metrics;
RUN;

DATA myxls.Features;
    SET fraud_data_features;
RUN;

LIBNAME myxls CLEAR;
