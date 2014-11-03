   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   MODULE INPUTTSSTABDERIV_B
   IMPLICIT NONE
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Definition of some parameters for Time Spectral stability      *
   !      * derivatives.                                                   *
   !      * The actual values of this parameters are arbitrary;            *
   !      * in the code always the symbolic names are (should be) used.    *
   !      *                                                                *
   !      *******************************************m***********************
   !
   ! TSStability : Whether or not the TS stability derivatives should
   !               be computed
   LOGICAL :: tsstability, tsalphamode, tsbetamode, tspmode, tsqmode, &
   & tsrmode, tsaltitudemode, tsmachmode
   ! useWindAxis : whether to rotate around the wind axis or the body
   !               axis...
   LOGICAL :: usewindaxis
   END MODULE INPUTTSSTABDERIV_B