!
!      ******************************************************************
!      *                                                                *
!      * File:          setpp3pp4Bwd.f90                                *
!      * Author:        Eirikur Jonsson, Peter Zhoujie Lyu              *
!      * Starting date: 10-14-2014                                      *
!      * Last modified: 10-21-2014                                      *
!      *                                                                *
!      ******************************************************************
!
       subroutine setpp3pp4Bwd(nn, pp3, pp4)
       
       use BCTypes
       use blockPointers
       use flowVarRefState
       implicit none
!
!      Subroutine arguments.
!
       integer(kind=intType), intent(in) :: nn
       real(kind=realType), dimension(imaxDim,jmaxDim) :: pp3, pp4

!
!      ******************************************************************
!      *                                                                *
!      * Begin execution                                                *
!      *                                                                *
!      ******************************************************************
!
       ! Determine the face id on which the subface is located and set
       ! the pointers accordinly.

       select case (BCFaceID(nn))
         case (iMin)
           pp3(1:je,1:ke) = p(3,1:je,1:ke)
           pp4(1:je,1:ke) = p(4,1:je,1:ke)
         case (iMax)
           pp3(1:je,1:ke) = p(nx,1:je,1:ke)
           pp4(1:je,1:ke) = p(nx-1,1:je,1:ke)
         case (jMin)
           pp3(1:ie,1:ke) = p(1:ie,3,1:ke)
           pp4(1:ie,1:ke) = p(1:ie,4,1:ke)
         case (jMax)
           pp3(1:ie,1:ke) = p(1:ie,ny,1:ke)
           pp4(1:ie,1:ke) = p(1:ie,ny-1,1:ke)
         case (kMin)
           pp3(1:ie,1:je) = p(1:ie,1:je,3)
           pp4(1:ie,1:je) = p(1:ie,1:je,4)
         case (kMax)
           pp3(1:ie,1:je) = p(1:ie,1:je,nz)
           pp4(1:ie,1:je) = p(1:ie,1:je,nz-1)
       end select

       end subroutine setpp3pp4Bwd   
       
