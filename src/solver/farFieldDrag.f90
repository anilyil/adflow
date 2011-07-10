!
!      ******************************************************************
!      *                                                                *
!      * File:          farField Drag.f90                               *
!      * Author:        Gaetan Kenway                                   *
!      * Starting date: 06-30-2011                                      *
!      * Last modified: 06-30-2011                                      *
!      *                                                                *
!      ******************************************************************
!
subroutine farFieldDrag()
  !
  !      ******************************************************************
  !      *                                                                *
  !      * farFieldDrag compuetes the total drag on the body using        *
  !      * a far-field method                                             *
  !      *                                                                *
  !      ******************************************************************
  !
  use blockPointers
  use BCTypes
  use flowVarRefState
  use inputPhysics
  use inputTimeSpectral
  use communication
  implicit none

  ! Woring Variables

  integer(kind=intType) :: nn,level,sps
  integer(kind=intType) :: i,j,k,ierr,liftindex

  ! Temporary Real Arrays:
  real(kind=realType), dimension(:,:,:,:), allocatable :: V_wind,fvw
  real(kind=realType), dimension(:,:,:), allocatable :: ds,dH,du_ir,res
  real(kind=realType) :: gm1
  real(kind=realType) :: alpha,beta

  ! Expansion Coefficients:
  real(kind=realType) :: ffp1,ffs1,ffh1,ffp2,ffs2,ffh2,ffps2,ffph2,ffsh2

  ! Ratios used in expansion:
  real(kind=realType) :: dPoP,dSoR,dHou2

  ! Drag Values:
  real(kind=realType) :: drag_local,drag

  ! Temp Variables for divergence calc
  real(kind=realType) :: qsp, qsm, rqsp, rqsm, porVel, porFlux
  real(kind=realType) :: pa, fs, sFace, vnp, vnm
  real(kind=realType) :: wx, wy, wz, rvol

  ! Define coefficients:
  ffp1 = -1/(gammaConstant*Mach**2)
  ffs1 = -1/(gammaConstant*Mach**2)
  ffh1 = 1.0

  ffp2 = -(1 + gammaConstant * Mach**2)/(2*gammaConstant**2*Mach**4)
  ffs2 = -(1 + gm1*Mach**2)/(2*gammaConstant**2*Mach**4)
  ffh2 = -1.0/2.0

  ffps2 = -(1 + gm1*Mach**2)/(gammaConstant**2*Mach**4)
  ffph2 = 1/(gammaConstant * Mach**2)
  ffsh2 = 1/(gammaConstant * Mach**2)

  call getDirAngle(velDirFreeStream,liftDirection,liftIndex,alpha,beta)

  level = 1
  gm1 = gammaConstant - 1.0_realType
  drag_local = 0.0
  do nn=1,nDom
     do sps=1,nTimeIntervalsSpectral
        call setPointers(nn,level,sps)

        ! Allocate memory for this block:
        allocate(V_wind(0:ib,0:jb,0:kb,3))
        allocate(ds(0:ib,0:jb,0:kb), &
                 dH(0:ib,0:jb,0:kb), &
                 du_ir(0:ib,0:jb,0:Kb),&
                 fvw(0:ib,0:jb,0:kb,3),&
                 res(0:ib,0:jb,0:kb))
        res(:,:,:) = 0.0
        ! Loop over owned cells + 1 level of halos:


        do k=1,nz
           do j=1,ny
              do i=1,nx                 
                 ! Compute the three components of the wind-oriented velocities:
                 call getWindAxis(w(i,j,k,ivx:ivz),V_wind(i,j,k,:),alpha)
                 
                 !The variation of Entropy wrt the free stream:
                 ds(i,j,k) = (RGas/gm1)*log((P(i,j,k)/Pinf)*(rhoInf/w(i,j,k,iRho))**gammaConstant)

                 ! The variation of Stagnation Enthalpy relative to free stream:
                 dH(i,j,k) = (gammaConstant/gm1)*(P(i,j,k)/w(i,j,k,iRho)-Pinf/rhoinf) + &
                      0.5*(( V_wind(i,j,k,1)**2 + V_wind(i,j,k,2)**2 + V_wind(i,j,k,3)**2) - Uinf**2)
                 

                 dPoP = (P(i,j,k)-Pinf)/Pinf
                 dSoR = ds(i,j,k)/RGas
                 dHou2 = dH(i,j,k)/Uinf**2

                 du_ir(i,j,k) = uInf*(ffp1*dPoP + ffs1*dSoR + ffH1*dHou2 + &
                                      ffp2*dPoP + ffs2*dSoR + ffH2*dHou2 + &
                                      ffps2*dPoP*dSoR + ffph2*dPoP**dHou2 + ffsh2*dSoR*dHou2)
                 

                 ! We should now be in a position to integrate the
                 ! irreversible drag over the volume:
                 !         /
                 ! D_irr = | div ( -rho * du_ir * V ) dV
                 !         /
                 !          V

                 ! produce the fvw vector:
                 fvw(i,j,k,:) = -w(i,j,k,iRho) * du_ir(i,j,k) * V_wind(i,j,k,:)
              end do
           end do
        end do

        sFace = zero
        do k=2,kl
           do j=2,jl
              do i=2,il
                 ! Fluxes in I
                 vnp = fvw(i+1,j,k,1)*sI(i,j,k,1) + fvw(i+1,j,k,2)*sI(i,j,k,2) + fvw(i+1,j,k,3)*sI(i,j,k,3)
                 vnm = fvw(i  ,j,k,1)*sI(i,j,k,1) + fvw(i  ,j,k,2)*sI(i,j,k,2) + fvw(i  ,j,k,3)*sI(i,j,k,3)
                 
                 if( addGridVelocities ) sFace = sFaceI(i,j,k)

                 porVel  = one
                 porFlux = half
                 if(porI(i,j,k) == noFlux)    porFlux = zero
                 if(porI(i,j,k) == boundFlux) then
                    porVel = zero
                    vnp    = sFace
                    vnm    = sFace
                 endif

                 ! Incorporate porFlux in porVel.

                 porVel = porVel*porFlux

                 ! Compute the normal velocities relative to the grid for
                 ! the face as well as the mass fluxes.
                 
                 qsp = (vnp -sFace)*porVel
                 qsm = (vnm -sFace)*porVel

                 fs = qsp + qsm

                 res(i+1,j,k) = res(i+1,j,k) - fs
                 res(i  ,j,k) = res(i+1,j,k) + fs

                 ! Fluxes in J
                 vnp = fvw(i,j+1,k,1)*sJ(i,j,k,1) + fvw(i,j+1,k,2)*sJ(i,j,k,2) + fvw(i,j+1,k,3)*sJ(i,j,k,3)
                 vnm = fvw(i,j  ,k,1)*sJ(i,j,k,1) + fvw(i,j  ,k,2)*sJ(i,j,k,2) + fvw(i,j  ,k,3)*sJ(i,j,k,3)
                 
                 if( addGridVelocities ) sFace = sFaceJ(i,j,k)

                 porVel  = one
                 porFlux = half
                 if(porJ(i,j,k) == noFlux)    porFlux = zero
                 if(porJ(i,j,k) == boundFlux) then
                    porVel = zero
                    vnp    = sFace
                    vnm    = sFace
                 endif

                 ! Incorporate porFlux in porVel.

                 porVel = porVel*porFlux

                 ! Compute the normal velocities relative to the grid for
                 ! the face as well as the mass fluxes.
                 
                 qsp = (vnp -sFace)*porVel
                 qsm = (vnm -sFace)*porVel

                 fs = qsp + qsm

                 res(i,j+1,k) = res(i,j+1,k) - fs
                 res(i,j  ,k) = res(i,j  ,k) + fs

                 ! Fluxes in K
                 vnp = fvw(i,j,k+1,1)*sK(i,j,k,1) + fvw(i,j,k+1,2)*sK(i,j,k,2) + fvw(i,j,k+1,3)*sK(i,j,k,3)
                 vnm = fvw(i,j,k  ,1)*sK(i,j,k,1) + fvw(i,j,k  ,2)*sK(i,j,k,2) + fvw(i,j,k  ,3)*sK(i,j,k,3)
                 
                 if( addGridVelocities ) sFace = sFaceK(i,j,k)

                 porVel  = one
                 porFlux = half
                 if(porK(i,j,k) == noFlux)    porFlux = zero
                 if(porK(i,j,k) == boundFlux) then
                    porVel = zero
                    vnp    = sFace
                    vnm    = sFace
                 endif

                 ! Incorporate porFlux in porVel.

                 porVel = porVel*porFlux

                 ! Compute the normal velocities relative to the grid for
                 ! the face as well as the mass fluxes.
                 
                 qsp = (vnp -sFace)*porVel
                 qsm = (vnm -sFace)*porVel

                 fs = qsp + qsm

                 res(i,j,k+1) = res(i,j,k+1) - fs
                 res(i,j,k  ) = res(i,j,k  ) + fs

              end do
           end do
        end do

        ! Now we have the divergence of fvw computed in res, we simply sum up the contributions:
        do k=2,kl
           do j=2,jl
              do i=2,il
                 drag_local = drag_local + res(i,j,k)*vol(i,j,k)
              end do
           end do
        end do
      
        deallocate(V_wind,ds,dH,du_ir,fvw,res)

     end do
  end do

  ! Reduce the drag to root proc:
  call mpi_reduce(drag_local,drag,1,sumb_real,mpi_sum,0,SUmb_comm_world,ierr)

  if (myid == 0) then
     print *,'Irreversable drag:',drag
  end if

end subroutine farFieldDrag

subroutine getWindAxis(V1,V2,alpha)

  ! Return vector V1 specified in body axis frame in wind axis frame. Only works for alpha (and not beta)
  use constants
  
  real(kind=realType) :: V1(3),V2(3),alpha

  if (liftIndex == 2) then

     call VectorRotation(V2(1),V2(2),V2(3),3, alpha, V1(1),V1(2),v1(3))

  else if (liftIndex==3) then

     call VectorRotation(V2(1),V2(2),V2(3),2,-alpha, V1(1),V1(2),v1(3))
  end if

end subroutine getWindAxis

