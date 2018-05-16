!*********************************************************************
!* Illinois Open Source License                                      *
!*                                                                   *
!* University of Illinois/NCSA                                       * 
!* Open Source License                                               *
!*                                                                   *
!* Copyright@2008, University of Illinois.  All rights reserved.     *
!*                                                                   *
!*  Developed by:                                                    *
!*                                                                   *
!*     Center for Simulation of Advanced Rockets                     *
!*                                                                   *
!*     University of Illinois                                        *
!*                                                                   *
!*     www.csar.uiuc.edu                                             *
!*                                                                   *
!* Permission is hereby granted, free of charge, to any person       *
!* obtaining a copy of this software and associated documentation    *
!* files (the "Software"), to deal with the Software without         *
!* restriction, including without limitation the rights to use,      *
!* copy, modify, merge, publish, distribute, sublicense, and/or      *
!* sell copies of the Software, and to permit persons to whom the    *
!* Software is furnished to do so, subject to the following          *
!* conditions:                                                       *
!*                                                                   *
!*                                                                   *
!* @ Redistributions of source code must retain the above copyright  * 
!*   notice, this list of conditions and the following disclaimers.  *
!*                                                                   * 
!* @ Redistributions in binary form must reproduce the above         *
!*   copyright notice, this list of conditions and the following     *
!*   disclaimers in the documentation and/or other materials         *
!*   provided with the distribution.                                 *
!*                                                                   *
!* @ Neither the names of the Center for Simulation of Advanced      *
!*   Rockets, the University of Illinois, nor the names of its       *
!*   contributors may be used to endorse or promote products derived * 
!*   from this Software without specific prior written permission.   *
!*                                                                   *
!* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,   *
!* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES   *
!* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND          *
!* NONINFRINGEMENT.  IN NO EVENT SHALL THE CONTRIBUTORS OR           *
!* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       * 
!* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   *
!* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE    *
!* USE OR OTHER DEALINGS WITH THE SOFTWARE.                          *
!*********************************************************************
!* Please acknowledge The University of Illinois Center for          *
!* Simulation of Advanced Rockets in works and publications          *
!* resulting from this software or its derivatives.                  *
!*********************************************************************
SUBROUTINE v3d4_mass(coor,lmcstet,matcstet, &
     rho,xm,numnp,numcstet,numat_vol,nstart,nend)

!!****f* Rocfrac/Rocfrac/Source/v3d4n_nl.f90
!!
!!  NAME
!!    v3d4_mass
!!
!!  FUNCTION
!!
!!    Computes the lumped mass matrix for a 4-node tetrahedral.
!!
!!  INPUTS
!!
!!   NumNP    -- Number of nodes
!!   numcstet -- Number of elements
!!   Coor     -- number of coordinates
!!   Matcstet  -- Material id
!!   rho      -- Density
!!   lmcstet  -- Nodal connectivity
!!   nstart, nend -- element beginning and end loop counter
!!   numat_vol -- number of materials
!!
!!  OUTPUT
!!
!!    xm -- lumped mass matrix
!!
!!****

  IMPLICIT NONE
  INTEGER :: numnp          ! number of nodes
  INTEGER :: numcstet       ! number of CSTets
  INTEGER :: numat_vol      ! number of materials
!--   densities
  REAL*8, DIMENSION(1:numat_vol) :: rho
!--   reciprical of mass matrix diagonal
  REAL*8, DIMENSION(1:numnp) :: xm
!--   material number for CSTet element
  INTEGER, DIMENSION(1:numcstet) :: matcstet
!--   connectivity table for CSTet elem
  INTEGER, DIMENSION(1:4,1:numcstet) :: lmcstet
!--   global coordinates
  REAL*8, DIMENSION(1:3,1:numnp) :: coor
!-- Displacement
  REAL*8, DIMENSION(1:3*numnp) :: Disp

  REAL*8 :: aa                 ! determinant of jacobian (2*area)
  REAL*8 :: x !,x1,x2,x3         ! dummy variable
  INTEGER :: m                 ! current element's material number
  INTEGER :: n1,n2,n3,n4,n5,n6 ! nodes, and dummy vars
  INTEGER :: n7,n8,n9,n10
  INTEGER :: i,nstart,nend     ! loop counter
!--  Coordinate holding variable
  REAL*8 :: x1,x2,x3,x4,y1,y2,y3,y4,z1,z2,z3,z4
!--  Coordinate subtractions
  REAL*8 :: x14, x24, x34, y14, y24, y34, z14, z24, z34
!--  
  REAL*8 :: c11, c21, c31
!--   6*volume and the volume      
  REAL*8 :: Vx6,volume
  
  DO i = nstart,nend
     m = matcstet(i)
     n1 = lmcstet(1,i)
     n2 = lmcstet(2,i)
     n3 = lmcstet(3,i)
     n4 = lmcstet(4,i)
     
     x1 = coor(1,n1)
     x2 = coor(1,n2)
     x3 = coor(1,n3)
     x4 = coor(1,n4)
     y1 = coor(2,n1)
     y2 = coor(2,n2)
     y3 = coor(2,n3)
     y4 = coor(2,n4)
     z1 = coor(3,n1)
     z2 = coor(3,n2)
     z3 = coor(3,n3)
     z4 = coor(3,n4)
     
     x14 = x1 - x4
     x24 = x2 - x4
     x34 = x3 - x4
     y14 = y1 - y4
     y24 = y2 - y4
     y34 = y3 - y4
     z14 = z1 - z4
     z24 = z2 - z4
     z34 = z3 - z4
     
     c11 =    y24*z34 - z24*y34
     c21 = -( x24*z34 - z24*x34 )
     c31 =    x24*y34 - y24*x34
     
     Vx6 = -( x14*c11 + y14*c21 + z14*c31 )
     
!!$        Vx6 = x2*y3*z4 - x2*y4*z3 - y2*x3*z4 + y2*x4*z3 + z2*x3*y4 
!!$     $        - z2*x4*y3 - x1*y3*z4 + x1*y4*z3 + x1*y2*z4 - x1*y2*z3
!!$     $        - x1*z2*y4 + x1*z2*y3 + y1*x3*z4 - y1*x4*z3 - y1*x2*z4 
!!$     $        + y1*x2*z3 + y1*z2*x4 - y1*z2*x3 - z1*x3*y4 + z1*x4*y3
!!$     $        + z1*x2*y4 - z1*x2*y3 - z1*y2*x4 + z1*y2*x3

     x = rho(m)*Vx6/24.d0 

     IF(x.LT.0.d0)THEN
        PRINT*,'ROCFRAC: ERROR'
        PRINT*,'ROCFRAC:    NEG, Volume... STOPPING'
        PRINT*,'ROCFRAC:  ELEMENT =',i
        PRINT*,'ROCFRAC:  NODES=',n1,n2,n3,n4
        PRINT*,'ROCFRAC:  x-Coordinates:',x1,x2,x3,x4
        PRINT*,'ROCFRAC:  y-Coordinates:',y1,y2,y3,y4
        PRINT*,'ROCFRAC:  z-Coordinates:',z1,z2,z3,z4
        STOP
     ENDIF
     
     xm(n1) = xm(n1) + x
     xm(n2) = xm(n2) + x
     xm(n3) = xm(n3) + x
     xm(n4) = xm(n4) + x  


  ENDDO
  
  RETURN
END SUBROUTINE v3d4_mass

