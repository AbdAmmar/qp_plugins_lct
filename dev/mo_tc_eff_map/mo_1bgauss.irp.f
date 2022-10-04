
BEGIN_PROVIDER [double precision, mo_j1b_gauss_hermI, (mo_num,mo_num)]

  BEGIN_DOC
  !
  !  :math:`\langle \chi_A | -0.5 \Delta \tau_{1b} | \chi_B \rangle` 
  !
  END_DOC

  implicit none

  mo_j1b_gauss_hermI = 0.d0
  call ao_to_mo(    j1b_gauss_hermI, size(   j1b_gauss_hermI, 1) &
               , mo_j1b_gauss_hermI, size(mo_j1b_gauss_hermI, 1) )

END_PROVIDER

! ---

BEGIN_PROVIDER [double precision, mo_j1b_gauss_hermII, (mo_num,mo_num)]

  BEGIN_DOC
  !
  !  :math:`\langle \chi_A | -0.5 \grad \tau_{1b} \cdot \grad \tau_{1b} | \chi_B \rangle` 
  !
  END_DOC

  implicit none

  mo_j1b_gauss_hermII = 0.d0
  call ao_to_mo(    j1b_gauss_hermII, size(   j1b_gauss_hermII, 1) &
               , mo_j1b_gauss_hermII, size(mo_j1b_gauss_hermII, 1) )

END_PROVIDER

! ---

BEGIN_PROVIDER [ double precision, mo_j1b_gauss_nonherm, (mo_num,mo_num)]

  BEGIN_DOC
  !
  ! \langle \chi_i | - grad \tau_{1b} \cdot grad | \chi_j \rangle 
  !
  END_DOC

  implicit none

  mo_j1b_gauss_nonherm = 0.d0
  call ao_to_mo(    j1b_gauss_nonherm, size(   j1b_gauss_nonherm, 1) &
               , mo_j1b_gauss_nonherm, size(mo_j1b_gauss_nonherm, 1) )
  
END_PROVIDER

! ---

