C THIS FILE CONTAINS THE HARD-CODED ARRAY DIMENSIONS FOR REGRID PROGRAMS
C THIS GETS RID OF DYNAMIC MEMORY ALLOCATION, WHICH CREATES PROBLEMS WITH G77
C
C MAX NUMBER OF ROWS IN ARCINFO 
      INTEGER DRC1
      PARAMETER (DRC1=194)
C MAX NUMBER OF COLUMNS IN ARCINFO 
      INTEGER DRC2
      PARAMETER (DRC2=174)
C MAX NUMBER OF ACTIVE CELLS IN BASIN
      INTEGER DNCELL
      PARAMETER (DNCELL=25200)
C MAX NUMBER OF STATIONS IN INPUT STATION INFORMATION FILE
      INTEGER DNSTATS
      PARAMETER (DNSTATS=900)
C MAX NUMBER OF NEAREST NEIGHBORS TO BE SEARCHED FOR STATIONS WITH DATA
      INTEGER DMAXNEIGH
      PARAMETER (DMAXNEIGH=100)
