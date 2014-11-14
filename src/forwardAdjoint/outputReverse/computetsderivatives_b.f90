   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of computetsderivatives in reverse (adjoint) mode (with options i4 dr8 r8 noISIZE):
   !   gradient     of useful results: lengthref dragdirection liftdirection
   !                moment dcdalphadot coef0 force dcdalpha
   !   with respect to varying inputs: machgrid lengthref machcoef
   !                dragdirection liftdirection gammainf pinf rhoinfdim
   !                pinfdim pref moment force
   !
   !     ******************************************************************
   !     *                                                                *
   !     * File:          computeTSDerivatives.f90                        *
   !     * Author:        C.A.(Sandy) Mader, G. Kenway                    *
   !     * Starting date: 11-25-2009                                      *
   !     * Last modified: 11-26-2009                                      *
   !     *                                                                *
   !     ******************************************************************
   !
   SUBROUTINE COMPUTETSDERIVATIVES_B(force, forceb, moment, momentb, &
   & liftindex, coef0, coef0b, dcdalpha, dcdalphab, dcdalphadot, &
   & dcdalphadotb, dcdq, dcdqdot)
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Computes the stability derivatives based on the time spectral  *
   !     * solution of a given mesh. Takes in the force coefficients at   *
   !     * all time instantces and computes the agregate parameters       *
   !     *                                                                *
   !     ******************************************************************
   !
   USE COMMUNICATION
   USE INPUTPHYSICS
   USE INPUTTIMESPECTRAL
   USE INPUTTSSTABDERIV
   USE FLOWVARREFSTATE
   USE MONITOR
   USE SECTION
   USE INPUTMOTION
   IMPLICIT NONE
   !
   !     Subroutine arguments.
   !
   REAL(kind=realtype), DIMENSION(3, ntimeintervalsspectral) :: force, &
   & moment
   REAL(kind=realtype), DIMENSION(3, ntimeintervalsspectral) :: forceb, &
   & momentb
   REAL(kind=realtype), DIMENSION(8) :: dcdq, dcdqdot
   REAL(kind=realtype), DIMENSION(8) :: dcdalpha, dcdalphadot
   REAL(kind=realtype), DIMENSION(8) :: dcdalphab, dcdalphadotb
   REAL(kind=realtype), DIMENSION(8) :: coef0
   REAL(kind=realtype), DIMENSION(8) :: coef0b
   INTEGER(kind=inttype) :: liftindex
   ! Working Variables
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral, 8) :: basecoef
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral, 8) :: basecoefb
   REAL(kind=realtype), DIMENSION(8) :: coef0dot
   REAL(kind=realtype), DIMENSION(8) :: coef0dotb
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral, 8) :: &
   & resbasecoef
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral, 8) :: &
   & resbasecoefb
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral) :: &
   & intervalalpha, intervalalphadot
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral) :: intervalmach&
   & , intervalmachdot
   REAL(kind=realtype), DIMENSION(nsections) :: t
   REAL(kind=realtype) :: alpha, beta
   INTEGER(kind=inttype) :: i, sps, nn
   !speed of sound: for normalization of q derivatives
   REAL(kind=realtype) :: a
   REAL(kind=realtype) :: ab
   REAL(kind=realtype) :: scaledim, fact, factmoment
   REAL(kind=realtype) :: scaledimb, factb, factmomentb
   ! Functions
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral) :: dphix, dphiy&
   & , dphiz
   REAL(kind=realtype), DIMENSION(ntimeintervalsspectral) :: dphixdot, &
   & dphiydot, dphizdot
   REAL(kind=realtype) :: derivativerigidrotangle, &
   & secondderivativerigidrotangle
   REAL(kind=realtype) :: TSALPHA, TSALPHADOT
   INTRINSIC SQRT
   REAL(kind=realtype) :: arg1
   REAL(kind=realtype) :: temp2
   REAL(kind=realtype) :: temp1
   REAL(kind=realtype) :: temp0
   REAL(kind=realtype) :: tempb6
   REAL(kind=realtype) :: tempb5
   REAL(kind=realtype) :: tempb4(8)
   REAL(kind=realtype) :: tempb3
   REAL(kind=realtype) :: tempb2
   REAL(kind=realtype) :: tempb1
   REAL(kind=realtype) :: tempb0
   REAL(kind=realtype) :: tempb
   REAL(kind=realtype) :: temp
   !
   !     ******************************************************************
   !     *                                                                *
   !     * Begin execution.                                               *
   !     *                                                                *
   !     ******************************************************************
   !
   scaledim = pref/pinf
   fact = two/(gammainf*pinf*machcoef**2*surfaceref*lref**2*scaledim)
   factmoment = fact/(lengthref*lref)
   IF (tsqmode) THEN
   STOP
   ! !q is pitch
   ! do sps =1,nTimeIntervalsSpectral
   !    !compute the time of this intervavc
   !    t = timeUnsteadyRestart
   !    if(equationMode == timeSpectral) then
   !       do nn=1,nSections
   !          t(nn) = t(nn) + (sps-1)*sections(nn)%timePeriod &
   !               /         (nTimeIntervalsSpectral*1.0)
   !       enddo
   !    endif
   !    ! Compute the time derivative of the rotation angles around the
   !    ! z-axis. i.e. compute q
   !    dphiZ(sps) = derivativeRigidRotAngle(degreePolZRot,   &
   !         coefPolZRot,     &
   !         degreeFourZRot,  &
   !         omegaFourZRot,   &
   !         cosCoefFourZRot, &
   !         sinCoefFourZRot, t)
   !    ! add in q_dot computation
   !    dphiZdot(sps) = secondDerivativeRigidRotAngle(degreePolZRot,   &
   !         coefPolZRot,     &
   !         degreeFourZRot,  &
   !         omegaFourZRot,   &
   !         cosCoefFourZRot, &
   !         sinCoefFourZRot, t)
   ! end do
   ! !now compute dCl/dq
   ! do i =1,8
   !    call computeLeastSquaresRegression(BaseCoef(:,i),dphiz,nTimeIntervalsSpectral,dcdq(i),coef0(i))
   ! end do
   ! ! now subtract off estimated cl,cmz and use remainder to compute 
   ! ! clqdot and cmzqdot.
   ! do i = 1,8
   !    do sps = 1,nTimeIntervalsSpectral
   !       ResBaseCoef(sps,i) = BaseCoef(sps,i)-(dcdq(i)*dphiz(sps)+Coef0(i))
   !    enddo
   ! enddo
   ! !now normalize the results...
   ! a  = sqrt(gammaInf*pInfDim/rhoInfDim)
   ! dcdq = dcdq*timeRef*2*(machGrid*a)/lengthRef
   ! !now compute dCl/dpdot
   ! do i = 1,8
   !    call computeLeastSquaresRegression(ResBaseCoef(:,i),dphizdot,nTimeIntervalsSpectral,dcdqdot(i),Coef0dot(i))
   ! enddo
   ELSE
   IF (tsalphamode) THEN
   DO sps=1,ntimeintervalsspectral
   !compute the time of this interval
   t = timeunsteadyrestart
   IF (equationmode .EQ. timespectral) THEN
   DO nn=1,nsections
   t(nn) = t(nn) + (sps-1)*sections(nn)%timeperiod/(&
   &             ntimeintervalsspectral*1.0)
   END DO
   END IF
   intervalalpha(sps) = TSALPHA(degreepolalpha, coefpolalpha, &
   &         degreefouralpha, omegafouralpha, coscoeffouralpha, &
   &         sincoeffouralpha, t)
   intervalalphadot(sps) = TSALPHADOT(degreepolalpha, &
   &         coefpolalpha, degreefouralpha, omegafouralpha, &
   &         coscoeffouralpha, sincoeffouralpha, t)
   basecoef(sps, 1) = fact*(force(1, sps)*liftdirection(1)+force(2&
   &         , sps)*liftdirection(2)+force(3, sps)*liftdirection(3))
   basecoef(sps, 2) = fact*(force(1, sps)*dragdirection(1)+force(2&
   &         , sps)*dragdirection(2)+force(3, sps)*dragdirection(3))
   basecoef(sps, 3) = force(1, sps)*fact
   basecoef(sps, 4) = force(2, sps)*fact
   basecoef(sps, 5) = force(3, sps)*fact
   basecoef(sps, 6) = moment(1, sps)*factmoment
   basecoef(sps, 7) = moment(2, sps)*factmoment
   basecoef(sps, 8) = moment(3, sps)*factmoment
   END DO
   !now compute dCl/dalpha
   DO i=1,8
   CALL COMPUTELEASTSQUARESREGRESSION(basecoef(:, i), &
   &                                       intervalalpha, &
   &                                       ntimeintervalsspectral, dcdalpha&
   &                                       (i), coef0(i))
   END DO
   ! now subtract off estimated cl,cmz and use remainder to compute 
   ! clalphadot and cmzalphadot.
   DO i=1,8
   DO sps=1,ntimeintervalsspectral
   resbasecoef(sps, i) = basecoef(sps, i) - (dcdalpha(i)*&
   &           intervalalpha(sps)+coef0(i))
   END DO
   END DO
   !now compute dCi/dalphadot
   DO i=1,8
   CALL COMPUTELEASTSQUARESREGRESSION(resbasecoef(:, i), &
   &                                       intervalalphadot, &
   &                                       ntimeintervalsspectral, &
   &                                       dcdalphadot(i), coef0dot(i))
   END DO
   a = SQRT(gammainf*pinfdim/rhoinfdim)
   tempb4 = 2*a*dcdalphadotb/lengthref
   tempb5 = 2*SUM(dcdalphadot*machgrid*dcdalphadotb)/lengthref
   machgridb = SUM(dcdalphadot*tempb4)
   ab = tempb5
   lengthrefb = lengthrefb - a*tempb5/lengthref
   dcdalphadotb = machgrid*tempb4
   temp2 = gammainf*pinfdim/rhoinfdim
   IF (temp2 .EQ. 0.0_8) THEN
   tempb6 = 0.0
   ELSE
   tempb6 = ab/(2.0*SQRT(temp2)*rhoinfdim)
   END IF
   gammainfb = pinfdim*tempb6
   pinfdimb = gammainf*tempb6
   rhoinfdimb = -(temp2*tempb6)
   resbasecoefb = 0.0_8
   DO i=8,1,-1
   coef0dotb = 0.0_8
   CALL COMPUTELEASTSQUARESREGRESSION_B(resbasecoef(:, i), &
   &                                      resbasecoefb(:, i), &
   &                                      intervalalphadot, &
   &                                      ntimeintervalsspectral, &
   &                                      dcdalphadot(i), dcdalphadotb(i), &
   &                                      coef0dot(i), coef0dotb(i))
   dcdalphadotb(i) = 0.0_8
   coef0dotb(i) = 0.0_8
   END DO
   basecoefb = 0.0_8
   DO i=8,1,-1
   DO sps=ntimeintervalsspectral,1,-1
   basecoefb(sps, i) = basecoefb(sps, i) + resbasecoefb(sps, i)
   dcdalphab(i) = dcdalphab(i) - intervalalpha(sps)*resbasecoefb(&
   &           sps, i)
   coef0b(i) = coef0b(i) - resbasecoefb(sps, i)
   resbasecoefb(sps, i) = 0.0_8
   END DO
   END DO
   DO i=8,1,-1
   CALL COMPUTELEASTSQUARESREGRESSION_B(basecoef(:, i), basecoefb(:&
   &                                      , i), intervalalpha, &
   &                                      ntimeintervalsspectral, dcdalpha(&
   &                                      i), dcdalphab(i), coef0(i), &
   &                                      coef0b(i))
   dcdalphab(i) = 0.0_8
   coef0b(i) = 0.0_8
   END DO
   factmomentb = 0.0_8
   factb = 0.0_8
   DO sps=ntimeintervalsspectral,1,-1
   momentb(3, sps) = momentb(3, sps) + factmoment*basecoefb(sps, 8)
   factmomentb = factmomentb + moment(3, sps)*basecoefb(sps, 8)
   basecoefb(sps, 8) = 0.0_8
   momentb(2, sps) = momentb(2, sps) + factmoment*basecoefb(sps, 7)
   factmomentb = factmomentb + moment(2, sps)*basecoefb(sps, 7)
   basecoefb(sps, 7) = 0.0_8
   momentb(1, sps) = momentb(1, sps) + factmoment*basecoefb(sps, 6)
   factmomentb = factmomentb + moment(1, sps)*basecoefb(sps, 6)
   basecoefb(sps, 6) = 0.0_8
   forceb(3, sps) = forceb(3, sps) + fact*basecoefb(sps, 5)
   factb = factb + force(3, sps)*basecoefb(sps, 5)
   basecoefb(sps, 5) = 0.0_8
   forceb(2, sps) = forceb(2, sps) + fact*basecoefb(sps, 4)
   factb = factb + force(2, sps)*basecoefb(sps, 4)
   basecoefb(sps, 4) = 0.0_8
   forceb(1, sps) = forceb(1, sps) + fact*basecoefb(sps, 3)
   factb = factb + force(1, sps)*basecoefb(sps, 3)
   basecoefb(sps, 3) = 0.0_8
   tempb2 = fact*basecoefb(sps, 2)
   factb = factb + (force(1, sps)*dragdirection(1)+force(2, sps)*&
   &         dragdirection(2)+force(3, sps)*dragdirection(3))*basecoefb(sps&
   &         , 2)
   forceb(1, sps) = forceb(1, sps) + dragdirection(1)*tempb2
   dragdirectionb(1) = dragdirectionb(1) + force(1, sps)*tempb2
   forceb(2, sps) = forceb(2, sps) + dragdirection(2)*tempb2
   dragdirectionb(2) = dragdirectionb(2) + force(2, sps)*tempb2
   forceb(3, sps) = forceb(3, sps) + dragdirection(3)*tempb2
   dragdirectionb(3) = dragdirectionb(3) + force(3, sps)*tempb2
   basecoefb(sps, 2) = 0.0_8
   tempb3 = fact*basecoefb(sps, 1)
   factb = factb + (force(1, sps)*liftdirection(1)+force(2, sps)*&
   &         liftdirection(2)+force(3, sps)*liftdirection(3))*basecoefb(sps&
   &         , 1)
   forceb(1, sps) = forceb(1, sps) + liftdirection(1)*tempb3
   liftdirectionb(1) = liftdirectionb(1) + force(1, sps)*tempb3
   forceb(2, sps) = forceb(2, sps) + liftdirection(2)*tempb3
   liftdirectionb(2) = liftdirectionb(2) + force(2, sps)*tempb3
   forceb(3, sps) = forceb(3, sps) + liftdirection(3)*tempb3
   liftdirectionb(3) = liftdirectionb(3) + force(3, sps)*tempb3
   basecoefb(sps, 1) = 0.0_8
   END DO
   ELSE
   machgridb = 0.0_8
   gammainfb = 0.0_8
   rhoinfdimb = 0.0_8
   pinfdimb = 0.0_8
   factmomentb = 0.0_8
   factb = 0.0_8
   END IF
   tempb = factmomentb/(lref*lengthref)
   factb = factb + tempb
   lengthrefb = lengthrefb - fact*tempb/lengthref
   temp1 = machcoef**2*scaledim
   temp0 = surfaceref*lref**2
   temp = temp0*gammainf*pinf
   tempb0 = -(two*factb/(temp**2*temp1**2))
   tempb1 = temp1*temp0*tempb0
   gammainfb = gammainfb + pinf*tempb1
   machcoefb = scaledim*temp*2*machcoef*tempb0
   scaledimb = temp*machcoef**2*tempb0
   pinfb = gammainf*tempb1 - pref*scaledimb/pinf**2
   prefb = scaledimb/pinf
   END IF
   END SUBROUTINE COMPUTETSDERIVATIVES_B