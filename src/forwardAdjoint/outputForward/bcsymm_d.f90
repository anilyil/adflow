   !        Generated by TAPENADE     (INRIA, Tropics team)
   !  Tapenade 3.10 (r5363) -  9 Sep 2014 09:53
   !
   !  Differentiation of bcsymm in forward (tangent) mode (with options i4 dr8 r8):
   !   variations   of useful results: *rev *p *w *rlv
   !   with respect to varying inputs: *rev *p *w *rlv *(*bcdata.norm)
   !   Plus diff mem management of: rev:in p:in gamma:in w:in rlv:in
   !                bcdata:in *bcdata.norm:in
   !
   !      ******************************************************************
   !      *                                                                *
   !      * File:          bcSymm.f90                                      *
   !      * Author:        Edwin van der Weide                             *
   !      * Starting date: 03-07-2003                                      *
   !      * Last modified: 06-12-2005                                      *
   !      *                                                                *
   !      ******************************************************************
   !
   SUBROUTINE BCSYMM_D(secondhalo)
   !
   !      ******************************************************************
   !      *                                                                *
   !      * bcSymm applies the symmetry boundary conditions to a block.    *
   !      * It is assumed that the pointers in blockPointers are already   *
   !      * set to the correct block on the correct grid level.            *
   !      *                                                                *
   !      * In case also the second halo must be set the loop over the     *
   !      * boundary subfaces is executed twice. This is the only correct  *
   !      * way in case the block contains only 1 cell between two         *
   !      * symmetry planes, i.e. a 2D problem.                            *
   !      *                                                                *
   !      ******************************************************************
   !
   USE BLOCKPOINTERS
   USE BCTYPES
   USE CONSTANTS
   USE FLOWVARREFSTATE
   USE ITERATION
   IMPLICIT NONE
   !
   !      Subroutine arguments.
   !
   LOGICAL, INTENT(IN) :: secondhalo
   !
   !      Local variables.
   !
   INTEGER(kind=inttype) :: kk, mm, nn, i, j, l
   REAL(kind=realtype) :: vn, nnx, nny, nnz
   REAL(kind=realtype) :: vnd
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1, gamma2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1d, rev2d
   INTERFACE 
   SUBROUTINE SETBCPOINTERS(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
   &       rev1, rev2, offset)
   USE BCTYPES
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   END SUBROUTINE SETBCPOINTERS
   SUBROUTINE RESETBCPOINTERS(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, &
   &       rev1, rev2, offset)
   USE BCTYPES
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   END SUBROUTINE RESETBCPOINTERS
   SUBROUTINE SETGAMMA(nn, gamma1, gamma2)
   USE BCTYPES
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   INTEGER(kind=inttype), INTENT(IN) :: nn
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1, gamma2
   END SUBROUTINE SETGAMMA
   SUBROUTINE RESETGAMMA(nn, gamma1, gamma2)
   USE BCTYPES
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   INTEGER(kind=inttype), INTENT(IN) :: nn
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1, gamma2
   END SUBROUTINE RESETGAMMA
   END INTERFACE
      INTERFACE 
   SUBROUTINE SETBCPOINTERS_D(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, &
   &       pp2, pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev1d, rev2, rev2d, &
   &       offset)
   USE BCTYPES
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   INTEGER(kind=inttype), INTENT(IN) :: nn, offset
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1, ww2
   REAL(kind=realtype), DIMENSION(:, :, :), POINTER :: ww1d, ww2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1, pp2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: pp1d, pp2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1, rlv2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rlv1d, rlv2d
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1, rev2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: rev1d, rev2d
   END SUBROUTINE SETBCPOINTERS_D
   SUBROUTINE SETGAMMA_D(nn, gamma1, gamma1d, gamma2, gamma2d)
   USE BCTYPES
   USE BLOCKPOINTERS
   USE FLOWVARREFSTATE
   IMPLICIT NONE
   INTEGER(kind=inttype), INTENT(IN) :: nn
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1, gamma2
   REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1d, &
   &       gamma2d
   END SUBROUTINE SETGAMMA_D
   END INTERFACE
      REAL(kind=realtype), DIMENSION(:, :), POINTER :: gamma1d
   !
   !      ******************************************************************
   !      *                                                                *
   !      * Begin execution                                                *
   !      *                                                                *
   !      ******************************************************************
   !
   ! Set the value of kk; kk == 0 means only single halo, kk == 1
   ! double halo.
   kk = 0
   IF (secondhalo) kk = 1
   ! Loop over the number of times the halo computation must be done.
   nhalo:DO mm=0,kk
   ! Loop over the boundary condition subfaces of this block.
   bocos:DO nn=1,nbocos
   ! Check for symmetry boundary condition.
   IF (bctype(nn) .EQ. symm) THEN
   ! Nullify the pointers, because some compilers require that.
   !nullify(ww1, ww2, pp1, pp2, rlv1, rlv2, rev1, rev2)
   ! Set the pointers to the correct subface.
   CALL SETBCPOINTERS_D(nn, ww1, ww1d, ww2, ww2d, pp1, pp1d, pp2, &
   &                      pp2d, rlv1, rlv1d, rlv2, rlv2d, rev1, rev1d, rev2&
   &                      , rev2d, mm)
   ! Set the additional pointers for gamma1 and gamma2.
   CALL SETGAMMA(nn, gamma1, gamma2)
   ! Loop over the generic subface to set the state in the
   ! halo cells.
   DO j=bcdata(nn)%jcbeg,bcdata(nn)%jcend
   DO i=bcdata(nn)%icbeg,bcdata(nn)%icend
   ! Store the three components of the unit normal a
   ! bit easier.
   ! Replace with actual BCData - Peter Lyu
   !nnx = BCData(nn)%norm(i,j,1)
   !nny = BCData(nn)%norm(i,j,2)
   !nnz = BCData(nn)%norm(i,j,3)
   ! Determine twice the normal velocity component,
   ! which must be substracted from the donor velocity
   ! to obtain the halo velocity.
   vnd = two*(ww2d(i, j, ivx)*bcdata(nn)%norm(i, j, 1)+ww2(i, j&
   &             , ivx)*bcdatad(nn)%norm(i, j, 1)+ww2d(i, j, ivy)*bcdata(nn&
   &             )%norm(i, j, 2)+ww2(i, j, ivy)*bcdatad(nn)%norm(i, j, 2)+&
   &             ww2d(i, j, ivz)*bcdata(nn)%norm(i, j, 3)+ww2(i, j, ivz)*&
   &             bcdatad(nn)%norm(i, j, 3))
   vn = two*(ww2(i, j, ivx)*bcdata(nn)%norm(i, j, 1)+ww2(i, j, &
   &             ivy)*bcdata(nn)%norm(i, j, 2)+ww2(i, j, ivz)*bcdata(nn)%&
   &             norm(i, j, 3))
   ! Determine the flow variables in the halo cell.
   ww1d(i, j, irho) = ww2d(i, j, irho)
   ww1(i, j, irho) = ww2(i, j, irho)
   ww1d(i, j, ivx) = ww2d(i, j, ivx) - vnd*bcdata(nn)%norm(i, j&
   &             , 1) - vn*bcdatad(nn)%norm(i, j, 1)
   ww1(i, j, ivx) = ww2(i, j, ivx) - vn*bcdata(nn)%norm(i, j, 1&
   &             )
   ww1d(i, j, ivy) = ww2d(i, j, ivy) - vnd*bcdata(nn)%norm(i, j&
   &             , 2) - vn*bcdatad(nn)%norm(i, j, 2)
   ww1(i, j, ivy) = ww2(i, j, ivy) - vn*bcdata(nn)%norm(i, j, 2&
   &             )
   ww1d(i, j, ivz) = ww2d(i, j, ivz) - vnd*bcdata(nn)%norm(i, j&
   &             , 3) - vn*bcdatad(nn)%norm(i, j, 3)
   ww1(i, j, ivz) = ww2(i, j, ivz) - vn*bcdata(nn)%norm(i, j, 3&
   &             )
   ww1d(i, j, irhoe) = ww2d(i, j, irhoe)
   ww1(i, j, irhoe) = ww2(i, j, irhoe)
   ! Simply copy the turbulent variables.
   DO l=nt1mg,nt2mg
   ww1d(i, j, l) = ww2d(i, j, l)
   ww1(i, j, l) = ww2(i, j, l)
   END DO
   ! Set the pressure and gamma and possibly the
   ! laminar and eddy viscosity in the halo.
  
   gamma1(i, j) = gamma2(i, j)
   pp1d(i, j) = pp2d(i, j)
   pp1(i, j) = pp2(i, j)
   IF (viscous) THEN
   rlv1d(i, j) = rlv2d(i, j)
   rlv1(i, j) = rlv2(i, j)
   END IF
   IF (eddymodel) THEN
   rev1d(i, j) = rev2d(i, j)
   rev1(i, j) = rev2(i, j)
   END IF
   END DO
   END DO
   CALL RESETGAMMA(nn, gamma1, gamma2)
   ! deallocation all pointer
   CALL RESETBCPOINTERS(nn, ww1, ww2, pp1, pp2, rlv1, rlv2, rev1&
   &                         , rev2, mm)
   END IF
   END DO bocos
   END DO nhalo
   END SUBROUTINE BCSYMM_D
