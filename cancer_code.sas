* Ustawienie biblioteki;
libname dane '/home/u63804391/sasuser.v94/js107779/ACT/ACT_projekt';

* Zmiana pliku xlsx na plik sas;
proc import datafile='/home/u63804391/sasuser.v94/js107779/ACT/ACT_projekt/cancer.xlsx'
            out=dane.cancer
            dbms=xlsx replace;

* Eksploracja zbioru;
proc contents data=dane.cancer out=vars;
run;

proc print data=vars;
run;

* Usuwanie niepotrzebnych kolumn;
data dane.cancer;
set dane.cancer (drop=Patient_ID Cancer_Type Overall_Survival_Status Relapse_Free_Status_Months Relapse_Free_Status Sex);
run;

* Eksploracja zmiennej zależnej;
proc freq data=dane.cancer;
   table Patient_Vital_Status;
run;

* Eksploracja zmiennej czasu;
proc freq data=dane.cancer;
   table Overall_Survival_Months;
run;

* Eksploracja pozostałych zmiennych;
proc freq data=dane.cancer;
table
Age_at_Diagnosis Type_of_Breast_Surgery	Cancer_Type_Detailed Cellularity Chemotherapy Pam50_and_Claudin_low_subtype Cohort ER_status_measured_by_IHC ER_Status Neoplasm_Histologic_Grade HER2_status_measured_by_SNP6 HER2_Status	Tumor_Other_Histologic_Subtype	Hormone_Therapy	Inferred_Menopausal_State Integrative_Cluster Primary_Tumor_Laterality Lymph_nodes_examined_positive Mutation_Count	Nottingham_prognostic_index	Oncotree_Code Overall_Survival_Months PR_Status	Radio_Therapy Three_Gene_classifier_subtype	Tumor_Size	Tumor_Stage	Patient_Vital_Status V;
run;

* Stworzenie zmiennej pomocniczej Age_at_Diagnosis_C dzielącej wiek na przedziały;
data dane.cancer;
set dane.cancer;
if Age_at_Diagnosis<50 then Age_at_Diagnosis_C=1;
if 51<=Age_at_Diagnosis<60 then Age_at_Diagnosis_C=2;
if 61<=Age_at_Diagnosis<70 then Age_at_Diagnosis_C=3;
if Age_at_Diagnosis>=71 then Age_at_Diagnosis_C=4;
run;

proc freq data=dane.cancer;
table
Age_at_Diagnosis_C;
run;

* Modele nieparametryczne;

* Tablice trwania życia;
proc lifetest data=dane.cancer method=lt plots=(s,h,p);
time Overall_Survival_Months*V(0);
run;

* Tablice trwania życia ze względu na zmienną Age_at_Diagnosis_C;
proc lifetest data=dane.cancer method=lt plots=(s,h);
time Overall_Survival_Months*V(0);
strata Age_at_Diagnosis_C;
run;

* Tablice trwania życia metodą  Kaplana-Meiera;
proc lifetest data=dane.cancer method=pl plots=(s, ls, lls);
time Overall_Survival_Months*V(0);
run;

* Modele parametryczne;

* Model wykładniczy;
proc lifereg data=dane.cancer;
model Overall_Survival_Months*V(0)= /dist=exponential;
run;

* Model wykładniczy ze zmiennymi objaśniającymi;
proc lifereg data=dane.cancer;
class Age_at_Diagnosis_C;
model Overall_Survival_Months*V(0)=Age_at_Diagnosis_C /dist=exponential;
run;

proc lifereg data=dane.cancer;
class Age_at_Diagnosis_C Type_of_Breast_Surgery Cancer_Type_Detailed Cellularity Chemotherapy Pam50_and_Claudin_low_subtype ER_status_measured_by_IHC Cohort ER_status_measured_by_IHC ER_Status Neoplasm_Histologic_Grade HER2_status_measured_by_SNP6 HER2_Status	Tumor_Other_Histologic_Subtype Hormone_Therapy	Inferred_Menopausal_State Integrative_Cluster Primary_Tumor_Laterality 	Oncotree_Code PR_Status	Radio_Therapy Three_Gene_classifier_subtype Tumor_Stage;
model Overall_Survival_Months*V(0)=Age_at_Diagnosis_C Type_of_Breast_Surgery Cancer_Type_Detailed Cellularity Chemotherapy Pam50_and_Claudin_low_subtype Cohort ER_status_measured_by_IHC ER_Status Neoplasm_Histologic_Grade HER2_status_measured_by_SNP6 HER2_Status	Tumor_Other_Histologic_Subtype Hormone_Therapy	Inferred_Menopausal_State Integrative_Cluster Primary_Tumor_Laterality Lymph_nodes_examined_positive Mutation_Count	Nottingham_prognostic_index	Oncotree_Code PR_Status	Radio_Therapy Three_Gene_classifier_subtype	Tumor_Size	Tumor_Stage	/dist=exponential;
run;

/* Step 1: Correlation Matrix */
proc corr data=dane.cancer;
    var Age_at_Diagnosis_C Type_of_Breast_Surgery Cancer_Type_Detailed Cellularity 
        Chemotherapy Pam50_and_Claudin_low_subtype Cohort ER_status_measured_by_IHC 
        ER_Status Neoplasm_Histologic_Grade HER2_status_measured_by_SNP6 HER2_Status 
        Tumor_Other_Histologic_Subtype Hormone_Therapy Inferred_Menopausal_State 
        Integrative_Cluster Primary_Tumor_Laterality Lymph_nodes_examined_positive 
        Mutation_Count Nottingham_prognostic_index Oncotree_Code PR_Status Radio_Therapy 
        Three_Gene_classifier_subtype Tumor_Size Tumor_Stage;
run;

/* Step 2: VIF (Variance Inflation Factor) */
proc reg data=dane.cancer;
    model Overall_Survival_Months = Age_at_Diagnosis_C Type_of_Breast_Surgery Cancer_Type_Detailed Cellularity 
        Chemotherapy Pam50_and_Claudin_low_subtype Cohort ER_status_measured_by_IHC 
        ER_Status Neoplasm_Histologic_Grade HER2_status_measured_by_SNP6 HER2_Status 
        Tumor_Other_Histologic_Subtype Hormone_Therapy Inferred_Menopausal_State 
        Integrative_Cluster Primary_Tumor_Laterality Lymph_nodes_examined_positive 
        Mutation_Count Nottingham_prognostic_index Oncotree_Code PR_Status Radio_Therapy 
        Three_Gene_classifier_subtype Tumor_Size Tumor_Stage;
    output out=vif_output;
run;


* Model wykładniczy przedziałami stały;
data dane.cancer_wyk_staly4;
set dane.cancer;
if Overall_Survival_Months<85 then przedz=1;
if Overall_Survival_Months>=85 and Overall_Survival_Months<170 then przedz=2;
if Overall_Survival_Months>=170 and Overall_Survival_Months<255 then przedz=3;
if Overall_Survival_Months>=255 then przedz=4;
do i=1 to przedz;
output;
end;
run;

data dane.cancer_wyk_staly4;
set dane.cancer_wyk_staly4;
	if V=0 then do;
		V1=0;
		if i=przedz then do;
			if i=1 then Overall_Survival_Months_1=Overall_Survival_Months;
			if i=2 then Overall_Survival_Months_1=Overall_Survival_Months-85;
			if i=3 then Overall_Survival_Months_1=Overall_Survival_Months-170;
			if i=4 then Overall_Survival_Months_1=Overall_Survival_Months-255;
		end;
		if i^=przedz then do;
			if i=1 then Overall_Survival_Months_1=85;
			if i=2 then Overall_Survival_Months_1=85;
			if i=3 then Overall_Survival_Months_1=85;
		end;
	end;

	if V=1 then do;
		if i=przedz then do;
			V1=1;
			if i=1 then Overall_Survival_Months_1=Overall_Survival_Months;
			if i=2 then Overall_Survival_Months_1=Overall_Survival_Months-85;
			if i=3 then Overall_Survival_Months_1=Overall_Survival_Months-170;
			if i=4 then Overall_Survival_Months_1=Overall_Survival_Months-255;
		end;
		if i^=przedz then do;
			V1=0;
			if i=1 then Overall_Survival_Months_1=85;
			if i=2 then Overall_Survival_Months_1=85;
			if i=3 then Overall_Survival_Months_1=85;
		end;
	end;
run;

proc lifereg data=dane.cancer_wyk_staly4;
class i;
model Overall_Survival_Months_1*V(0)=i /dist=exponential;
run;

* Model Weibulla;
proc lifereg data=dane.cancer;
model Overall_Survival_Months*V(0)= /dist=weibull;
run;

* Model Gamma;
proc lifereg data=dane.cancer;
model Overall_Survival_Months*V(0)= /dist=gamma;
run;

* Model log-logistyczny;
proc lifereg data=dane.cancer;
model Overall_Survival_Months*V(0)= /dist=llogistic;
run;

* Model logarytmiczno-normalny;
proc lifereg data=dane.cancer;
model Overall_Survival_Months*V(0)= /dist=lnormal;
run;
