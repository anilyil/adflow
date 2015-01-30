!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
!  differentiation of boundarynormals in forward (tangent) mode (with options i4 dr8 r8):
!   variations   of useful results: *(*bcdata.norm)
!   with respect to varying inputs: *si *sj *sk
!   plus diff mem management of: si:in sj:in sk:in bcdata:in *bcdata.norm:in
subroutine boundarynormals_d()
!
!  **************************************************************
!  *                                                            *
!  * the unit normals on the boundary faces. these always point *
!  * out of the domain, so a multiplication by -1 is needed for *
!  * the imin, jmin and kmin boundaries.                        *
!  *                                                            *
!  **************************************************************
!
  use blockpointers
  use bctypes
  use diffsizes
!  hint: isize1ofdrfbcdata should be the size of dimension 1 of array *bcdata
  implicit none
  integer(kind=inttype) :: i, j, ii, mm
  real(kind=realtype) :: xp, yp, zp, mult, fact
  real(kind=realtype) :: xpd, ypd, zpd, factd
  intrinsic mod
  intrinsic sqrt
  real(kind=realtype) :: arg1
  real(kind=realtype) :: arg1d
  integer :: ii1
  do ii1=1,isize1ofdrfbcdata
    bcdatad(ii1)%norm = 0.0_8
  end do
  xpd = 0.0_8
  ypd = 0.0_8
  zpd = 0.0_8
! loop over the boundary subfaces of this block.
bocoloop:do mm=1,nbocos
! loop over the boundary faces of the subface.
    do ii=0,(bcdata(mm)%jcend-bcdata(mm)%jcbeg+1)*(bcdata(mm)%icend-&
&       bcdata(mm)%icbeg+1)-1
      i = mod(ii, bcdata(mm)%icend - bcdata(mm)%icbeg + 1) + bcdata(mm)%&
&       icbeg
      j = ii/(bcdata(mm)%icend-bcdata(mm)%icbeg+1) + bcdata(mm)%jcbeg
      select case  (bcfaceid(mm)) 
      case (imin) 
        mult = -one
        xpd = sid(1, i, j, 1)
        xp = si(1, i, j, 1)
        ypd = sid(1, i, j, 2)
        yp = si(1, i, j, 2)
        zpd = sid(1, i, j, 3)
        zp = si(1, i, j, 3)
      case (imax) 
        mult = one
        xpd = sid(il, i, j, 1)
        xp = si(il, i, j, 1)
        ypd = sid(il, i, j, 2)
        yp = si(il, i, j, 2)
        zpd = sid(il, i, j, 3)
        zp = si(il, i, j, 3)
      case (jmin) 
        mult = -one
        xpd = sjd(i, 1, j, 1)
        xp = sj(i, 1, j, 1)
        ypd = sjd(i, 1, j, 2)
        yp = sj(i, 1, j, 2)
        zpd = sjd(i, 1, j, 3)
        zp = sj(i, 1, j, 3)
      case (jmax) 
        mult = one
        xpd = sjd(i, jl, j, 1)
        xp = sj(i, jl, j, 1)
        ypd = sjd(i, jl, j, 2)
        yp = sj(i, jl, j, 2)
        zpd = sjd(i, jl, j, 3)
        zp = sj(i, jl, j, 3)
      case (kmin) 
        mult = -one
        xpd = skd(i, j, 1, 1)
        xp = sk(i, j, 1, 1)
        ypd = skd(i, j, 1, 2)
        yp = sk(i, j, 1, 2)
        zpd = skd(i, j, 1, 3)
        zp = sk(i, j, 1, 3)
      case (kmax) 
        mult = one
        xpd = skd(i, j, kl, 1)
        xp = sk(i, j, kl, 1)
        ypd = skd(i, j, kl, 2)
        yp = sk(i, j, kl, 2)
        zpd = skd(i, j, kl, 3)
        zp = sk(i, j, kl, 3)
      end select
! compute the inverse of the length of the normal vector
! and possibly correct for inward pointing.
      arg1d = xpd*xp + xp*xpd + ypd*yp + yp*ypd + zpd*zp + zp*zpd
      arg1 = xp*xp + yp*yp + zp*zp
      if (arg1 .eq. 0.0_8) then
        factd = 0.0_8
      else
        factd = arg1d/(2.0*sqrt(arg1))
      end if
      fact = sqrt(arg1)
      if (fact .gt. zero) then
        factd = -(mult*factd/fact**2)
        fact = mult/fact
      end if
! compute the unit normal.
      bcdatad(mm)%norm(i, j, 1) = factd*xp + fact*xpd
      bcdata(mm)%norm(i, j, 1) = fact*xp
      bcdatad(mm)%norm(i, j, 2) = factd*yp + fact*ypd
      bcdata(mm)%norm(i, j, 2) = fact*yp
      bcdatad(mm)%norm(i, j, 3) = factd*zp + fact*zpd
      bcdata(mm)%norm(i, j, 3) = fact*zp
    end do
  end do bocoloop
end subroutine boundarynormals_d
