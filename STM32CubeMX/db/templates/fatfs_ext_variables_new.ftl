[#ftl]
[#-- To be generated in the fatfs.h file --]
[#--  Used because of a new code in Middleware.java --]
[#list IPdatas as IP]  
[#assign ipvar = IP]
[#list IP.configModelList as instanceData]
        [#assign instName = instanceData.instanceName]
        [#assign instMode= instanceData.halMode]
		[#assign ipName = instanceData.ipName]
extern FATFS ${instName}FatFs;    /* File system object for ${instName} logical drive */
extern FIL ${instName}File;       /* File  object for ${instName} */
extern char ${instName}Path[4];   /* ${instName} logical drive path */
[#-- FATFS ${instName}_FatFs; --]
[#-- extern Diskio_drvTypeDef ${instName}_Driver; --]
[/#list]
[/#list]
