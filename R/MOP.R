#' Calculates distance measures between numerous groups of reference set of points (M) in n-dimensional space with each point in another set (G). 
#' 
#' Noninteractive version. For interactive version refer \link{iMOP}
#' 
#' Function MOP also marks areas where extrapolation could occur during niche modeling exercise for careful model interpretation. 
#' This function is especially useful when developed niche model in projected to different space or time. 
#' For more details refer DOI: 10.1016/j.ecolmodel.2013.04.011
#' The function will return a list of length 3 or 4, depending upon MxMESS parameter. If MxMESS is set to Y then it returns a list of 3 items
#' First object in list is - MOP matrix, Second object in list is ? Maxent MESS matrix, Third object in list is - Matrix of resampled M. 
#' If MxMESS parameter is to N then return list contains 2 objects, 1st - MOP matrix, 2nd - Matrix of resampled M
#' Input parameters required for this function are 
#' @import fields 
#' @import raster 
#' @importFrom grDevices dev.new
#' @param FileType - File types of reference and extent area. 
#'               A - ASC format files. Parameter m1 and m2 are required, if FileType is set to A 
#'               M - Files in text format, for files in text format. Parameter InpRefFile and InpExtentFile are required, if FileType is set to M
#'               The format of the file should be Longitude, Latitude, Var1, Var2,...... and so on. Also make sure that reference and extent 
#'               file in text format has same sequence of variables. 
#' @param m1 - List of .asc file for reference area (M). For example, ("C://data//Bio1_M.asc", "C://data//Bio2_M.asc","C://data//Bio3_M.asc")
#'         Supply this list, when FileType parameter is set to A. Make sure that order of variables is same in reference and exent.
#' @param m2 - List of .asc file for extent area (G). For example, ("C://data//Bio1_G.asc", "C://data//Bio2_G.asc","C://data//Bio3_G.asc"). 
#'         Supply this list, when FileType parameter is set to A. Make sure that order of variables is same in reference and exent
#' @param InpRefFile - Name of file containing reference data (M) for distance calculation. Format of the file should be 
#'           Longitude, Latitude, Var1, Var2,...... and so on.
#' @param InpExtentFile - Name of file containing extent data (G) for distance calculation. Format of the file should be 
#'         Longitude, Latitude, Var1, Var2,...... and so on. Order of variables in Reference (M) and Extent (G) data should be maintained.
#' @param p1 - Subsampling percentage for reference area (M) (proportion of points from M to be randomly sampled if M is too large). 
#'         Value must be between (>0 and <=1).
#' @param p2 - Subsampling percentage for Extent area (G) (proportion of points from G to be randomly sampled if G is too large). 
#'         Value must be between (>0 and <=1).
#' @param decil - Series of number seperated by comma, which signifies what proportion of closest points in M is to be compared. 
#' @param MxMESS - A boolean variable for generating Maxent MESS, if MxMESS = Y, generate Maxent MESS , if MxMESS = N do not generate Maxent MESS
#' @param GetAns - Option is Y or N. If Y, the provide file name to save reference data and extent data seperately. This parameter is necessary, 
#'         if the FileType parameter is set to A.
#' @param OPRefFileName - Name of file in which reference data (M) will be saved in .txt format for future use. Supply this parameter when
#'         GetAns = Y and FileType = A 
#' @param OPExtentFileName - Name of file in which extent data (G) will be saved in .txt format for future use. Supply this parameter when
#'         GetAns = Y and FileType = A 
#' @param FlList - List for filenames with folder names. This files will store the generated MOP maps. Number of filenames should be equal to 
#'         number of decil provided
#' @param SampleMName - Provide file name with folder names. If the reference area is too big and p1 is less than 1, then choice is to save this resampled data in the file for 
#'         future use. 
#' @param SampleGName - Provide file name with folder names. If the reference area is too big and p1 is less than 1, then choice is to save this resampled data in the file for 
#'         future use. 
#' @param MxMESSOpFile - If MxMESS is set to Y, and want to save maxent MESS results in a file, then provide file name with folder in this parameter.
#' @examples \dontrun{
#' MOP()
#' }
#' @export


## Main function. This function calls other function. To run the MOP Program run MainMESS(). This program requires raster and fields packages.

MOP <- function(FileType=NA, m1=NA, m2=NA, InpRefFile=NA, InpExtentFile=NA, 
                p1=NA, p2=NA, decil=NA, MxMESS=NA, GetAns=NA, 
                OPRefFileName=NA, OPExtentFileName=NA, FlList=NA, 
                SampleMName=NA, SampleGName=NA, MxMESSOpFile=NA)
{
  Valid = TRUE
  ## Input data can be in matrix format or ASCII grid format. When the data is in matrix format, the structure should be X,Y,Var1,Var2..... for extent and reference
  ## matrix. The variable names should be same in both the files.
  ## If the data is in ASCII format, then ASCII file names should be same for extent and reference dataset. While selecting the files make sure that files are selected
  ## in sequence. (Reason, Raster package is not able to understand the file names, but it converts them to layer_1 layer_2......
  if(is.na(FileType)){
    stop("Please specify FileType (ASCII format files or Matrix in text format A/M) or use 
         iMOP for interactive version")
  }
  switch(FileType,
         A = { if (is.na(m1[1])){
           stop("Please specify m1 (Reference Files) or use iMOP for interactive version")
           if (length(m1) == 0 )
           {
             Valid = FALSE
           }
         }
           else {m1 = ReadASCII ("Choose Reference Files",m1)}
           
           if (is.na(m2[1])){
             stop("Please specify m2 (Reference Files) or use iMOP for interactive version")
             if (length(m2) == 0 )
             {
               Valid = FALSE
             }		   
           }
           else {m2 = ReadASCII ("Choose Projected Files",m2)}
         },
         M = { if (is.na(InpRefFile)){
           InpRefFile = file.choose("Choose Reference File : ")
           m1 = read.table(InpRefFile, header=T, sep = ",")
         }
           else {m1 = read.table(InpRefFile, header=T, sep = ",")}
           if (is.na(InpExtentFile)){
             InpExtentFile = file.choose("Choose Extent File : ")
             m2 = read.table(InpExtentFile, header=T, sep = ",")
           }
           else{m2 = read.table(InpExtentFile, header=T, sep = ",")}
         },
         { Valid = FALSE  })
  
  if (Valid == TRUE)
  {
    d1 = dim(m1)
    ## l1 stores the column numbers containing the variables for comparison. 
    l1 = seq(3,d1[2])
    
    ## In real life examples, M and G are large, thus cannot process due to memory limitation. Take the random sample of this dataset by providing the percentages. 1 being all the 
    ## pixels / rows
    print(paste("Total reference points : ", dim(m1)[1]))
    print(paste("Total extent points : ", dim(m2)[1]))
    if (is.na(p1)){
      p1 = readline("Enter percentage of reference points for resampling (0 > and <= 1) : ")
    }
    if (is.na(p2)){
      p2 = readline("Enter percentage of extent points for resampling (0 > and <= 1) : ")   
    }
    ## decil is the percentage with which every point is G is compared with M.
    if (is.na(decil)){   
      decil = readline("Enter % of reference points to compare with a point in extent (1-100) : ")
    }
    if (is.na(MxMESS)){ 
      MxMESS = readline("Do you want Maxent MESS (Y/N) : ")
    }
    ## This is the main function which generate MOP values. 
    t2 = MOP_NB (m1, m2, l1, l1, decil, as.numeric(p1), as.numeric(p2), 1, 2, MxMESS, FlList, SampleMName, SampleGName, MxMESSOpFile)
    
    ### Here give the option to save the point file into matrix if that is required for usage later    
    
    if (FileType == "A")
    {
      GetAns = readline("Want to save reference & extent files for further use in matrix format? (Y/N) : ")
      if (GetAns == "Y")
      {
        OPRefFileName = readline("Reference File Name to save in matrix format : ")
        OPExtentFileName = readline("Extent File Name to save in matrix format : ")
        write.table(m1,OPRefFileName, row.names=F, col.names = T, sep = ",")
        write.table(m2, OPExtentFileName, row.names=F, col.names = T, sep = ",")
      }
    }
    return(t2)
  }
  else { print ("Error in input") }
  
}


MOP_NB <- function(m1, m2, c1, c2, decil, p1, p2, Xcol, Ycol, MxMESS, FlList, SampleMName, SampleGName, MxMESSOpFile)
{
  # m1 is the reference cloud (M) against which we test points in m2 (G). Both should be matrices of nXv, n=pixels and v=variables
  # c1 and c2 are the vectors containing the columns in m1 and m2 that contain the variables to be used. Obviously their length should be the same..
  # decil is the number (1,2,...100) of the decil that will be used for the comparison. if total pixels in the data is less than 100 then decil will 
  # be converted from 1-10, where 1 means lower 10%, 2 lower 20%, 10 means the mean of every point in M.
  # iM contains the row-indices of the sample of reference points, and iG the sample of points in the copmplete area G. In real cases, M and G contains lot of pixels.
  # Due to memory limitations, M and G may need to be subsampled 
  #
  di1 = dim(m1)[1]
  di2 = dim(m2)[1]
  iM = sample(1:di1, round(p1*di1), replace=F)
  iG = sample(1:di2, round(p2*di2), replace=F)
  M = as.matrix(m1[iM,])
  G = as.matrix(m2[iG,])
  
  ## Can generate no of percentages to compare with. Changing the decil. 
  Percentages = as.numeric(strsplit(decil,",")[[1]])
  TotPercent = length(Percentages)
  
  m2 = as.matrix(m2)
  # This matrix stored MOP euclidian distance
  med = matrix(0,nrow=dim(m2)[[1]], ncol=TotPercent)
  
  
  #
  # Calculation of the MESS
  # Matrix pm contains the minimum value of each variable in the reference set(M).
  # Matrix pM contains the maximum value of each variable in the reference set(M)
  # And matrix f contains the proportion of points in M smaller than the corresponding variable in a reference point
  # And sim will contain the MESS similarities with respect to each variable
  #  
  if (MxMESS == "Y")
  {
    
    #medMxM storess the MESS distances for the subsampled M and not the occurrences.
    medMxM = matrix(0,nrow=dim(m2)[[1]], ncol=TotPercent)
    pm = matrix(0,nrow=1,ncol=length(c1))
    pM = matrix(0,nrow=1,ncol=length(c1))
    f = matrix(0,nrow=1,ncol=length(c1))
    sim = matrix(0,nrow=1,ncol=length(c1))
    #
    #  
    for (j in 1:length(c1))
    {
      pm[1,j] = min(m1[iM,c1[[j]]])
      pM[1,j] = max(m1[iM,c1[[j]]])
    }
    
  } ## If MxMESS
  
  ## M is big and G is small 
  
  EucDist = rdist(M[,3:dim(M)[2]], G[,3:dim(G)[2]])
  namelist = c()
  for (CurDecil in 1:TotPercent)
  {
    
    CurCol = 1
    for(i in iG)
    {
      
      di = EucDist[,CurCol]
      
      if (length(di) > 100) 
      {
        qdi = quantile(di,probs=seq(0,1,length=100),na.rm=T)
        ii = which(di<=qdi[[Percentages[CurDecil]]])
      }
      else
      {
        
        qdi = quantile(di,probs=seq(0,1,length=10),na.rm=T)	 
        ii = which(di<=qdi[[Percentages[CurDecil]/10]])	   
      }
      
      med[i,CurDecil] = mean(di[ii])
      CurCol = CurCol + 1
      #
      # MESS = Maxent MESS formula
      #
      if (MxMESS == "Y")
      {
        for(j in 1:length(c1))
        {
          f[1,j] = 100 * length(which(m1[iM, c1[[j]]] < m2[i,c2[[j]]])) / length(iM)
        }
        
        for (j in 1:length(c1))
        {
          sim[1,j] = (f[1,j]==0)*(m2[i,c2[[j]]]-pm[1,j])*100/(pM[1,j]-pm[1,j])+(f[1,j]>0 & f[1,j]<50)*2*f[1,j]+(f[1,j]>=50 & f[1,j]<100)*2*(100-f[1,j])+(f[1,j]==100)*(pM[1,j]-m2[i,c2[[j]]])*100/(pM[1,j]-pm[1,j])
        }
        medMxM[i,1]=min(sim)
      } ## If MxMESS
    } ## for i in iG
    
    
    # The return objects are part of the list name to which MESS is equaled (you invoke this as name=MESS(m1,m2,c1,c2,dec,p1,p2)
    #the first part of the object is our MESS value, the second and third the indices in the original matrices with samples taken, and the fourth the value of Maxent MESS
    
    
    print("MESS values generated. Now plotting... :) !!")
    
    ## Adding the plot in the program New addition
    
    nonzero = which(med[,CurDecil] > 0)
    RangeMed = range(med[nonzero,CurDecil])
    
    clr = med[nonzero,CurDecil] / RangeMed[2]
    
    NewM2 = m2[nonzero,c(Xcol,Ycol)]
    
    dev.new()
    plot(m2[nonzero,Xcol], m2[nonzero, Ycol], pch = 15, col=hsv(clr,1,1), cex = 1, xlab = "Longitude", ylab = "Latitude", main = paste("With ", Percentages[CurDecil], "%") )
    
    ## Get the row no's where environmental values are outside the range in M		
    Outvec = PlotOut(m1, m2)
    
    PlotBlack = intersect(nonzero,Outvec)
    if (length(PlotBlack) > 0)
    {
      points(m2[PlotBlack,Xcol], m2[PlotBlack, Ycol], pch = 15, col="black", cex = 1)
      med[PlotBlack,CurDecil] = -9999
      
    } 
    if (is.na(FlList[1])){ 
      SavePlot = readline("Plot generated. Save the plot file ? (Y/N) : ")
      if (SavePlot == "Y")
      {
        FlName = readline("Enter file name : ")
        dev.copy(jpeg,filename=FlName);
        dev.off ()
      }
    }
    else
    {
      FlName = FlList[CurDecil]
      dev.copy(jpeg,filename=FlName);
      dev.off ()
      
    }
    print (paste ("Completed percentage value ", Percentages[CurDecil], "."))
    
    namelist = c(namelist, paste(Percentages[CurDecil], " %",sep = " " ))
  } ## for decil length 
  
  ### Here concatenating the X Y columns to med. Structure of med is first 2 columns X and Y, from 3rd column decile percentage starts.. total columns depends upon the user input. 
  ### the last column contains 0 / 1, where 1 means this particular rows is selected while resampling. 
  ### 
  RandomG = rep(0,dim(m2)[1])
  RandomG[iG] = 1
  med = cbind(m2[,1:2], med, RandomG)
  med1 = as.data.frame(med)
  names(med1) = c("X","Y", namelist, "RandomG")
  med = as.matrix(med1)
  
  ## OutM - A matrix with X, Y and third column, containing 0 or 1. Value 1 indicates that this particular row was selected while taking the random sample. 
  ## This matrix is saved if user wants to use this data later for any purpose. 
  RandomM = rep(0,dim(m1)[1])
  RandomM[iM] = 1
  OutM = cbind(m1[,1:2], RandomM)
  ### Here saving the resampled file for further use   
  
  ### Saving the resampled reference file.
  if (is.na(SampleMName)){
    SaveFile = readline("Do you want to save resampled reference file (Y/N) : ")
    if (SaveFile =="Y")
    {
      OutM = as.data.frame(OutM)
      names(OutM) = c("X","Y","RndM")
      SampleMName = readline("File name for resampled reference : ")
      write.table(OutM, SampleMName, row.names=F, col.names =T, sep = ",")
    }
  }
  else
  {
    OutM = as.data.frame(OutM)
    names(OutM) = c("X","Y","RndM")
    write.table(OutM, SampleMName, row.names=F, col.names =T, sep = ",")  
  } 
  ### Saving the MOP extent file
  if (is.na(SampleGName)){
    SaveFile = readline("Do you want to save MOP results in matrix format? (Y/N) : ")
    if (SaveFile == "Y")
    {
      SampleGName = readline("File name for MOP result : ")
      write.table(med, SampleGName, row.names=F, col.names = T, sep = ",")
    }
  }
  else
  {
    write.table(med, SampleGName, row.names=F, col.names = T, sep = ",")
  }
  
  if (MxMESS == "Y")
  {
    ### Saving the MESS extent file
    if (is.na(MxMESSOpFile)){
      SaveFile = readline("Do you want to save Maxent MESS results in matrix format? (Y/N) : ")
      if (SaveFile == "Y")
      {
        MxMESSOpFile = readline("File name for Maxent MESS result : ")
        #write.table(medMxM, SampleGName, row.names=F, col.names = T, sep = ",")
        write.table(cbind(m2[,1:2], medMxM[,1]), MxMESSOpFile, row.names=F, col.names = T, sep = ",")
      }
    }
    else
    {
      write.table(cbind(m2[,1:2], medMxM[,1]), MxMESSOpFile, row.names=F, col.names = T, sep = ",")
    }
    
    ## return(list(med,medMxM,iM,iG, OutM))
    return(list(med, medMxM[ ,1], OutM))	
  }
  else
  {
    ## return(list(med,iM,iG, OutM))
    return(list(med, OutM))	
  }
}



## This function collects all the rows outside the range of any of the environmental variable and will be plotted in black color later.  
PlotOut <- function (M1, G1)
{
  d1 = dim(M1)
  AllVec = matrix(0,0,0)
  for (i in 3:d1[2])
  {
    MRange = range(M1[,i])
    l1 = which(G1[,i] < range(M1[,i])[1] | G1[,4] > range(M1[,4])[2])
    AllVec = c(l1,AllVec)
  }
  AllVec = unique(AllVec)
  
  return(AllVec)
}


ReadASCII <- function(Prompt,Lst1)
{
  if (length(Lst1) == 0 )
  {
    Mfiles = choose.files(caption=Prompt)
  } else {Mfiles = Lst1}
  
  if (length(Mfiles) > 0)
  {
    Mstack = MakeStack(Mfiles)
    Mpt = rasterToPoints(Mstack)
    return(Mpt)
  }   else {return(Mfiles)}
}

## Function to create stack of the environmental files.
MakeStack <- function(Mfiles)
{
  for (i in 1: length(Mfiles))
  {
    fl1 = raster(Mfiles[i])
    if (i == 1)
    {
      stk = stack(fl1)
    }
    else
    {
      stk = stack(stk, fl1)
    }
    
  }
  return(stk)
}
