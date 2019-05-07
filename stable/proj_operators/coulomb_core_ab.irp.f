
 BEGIN_PROVIDER [integer, n_core_orb_for_hf]
 implicit none
 integer :: i
 n_core_orb_for_hf = 0
 do i = 1, elec_alpha_num
  if(  trim(mo_class(i))=="Core" )then
   n_core_orb_for_hf +=1 
  endif
 enddo

 END_PROVIDER 

BEGIN_PROVIDER [integer, list_core_orb_for_hf, (n_core_orb_for_hf)]
 implicit none
 integer :: i,j
 j = 0
 do i = 1, elec_alpha_num
  if(  trim(mo_class(i))=="Core" )then
   j +=1 
   list_core_orb_for_hf(j) = i
  endif
 enddo

END_PROVIDER 

BEGIN_PROVIDER [double precision, integrals_for_core_hf_pot, (mo_num,mo_num,n_max_valence_orb_for_hf,n_max_valence_orb_for_hf)]
 implicit none
 integer :: i_i,i_j,i,j,i_m,i_n,m,n
 double precision :: get_two_e_integral
 do i_m = 1, n_core_orb_for_hf! electron 1 
  m = list_core_orb_for_hf(i_m)
  do i_n = 1, n_core_orb_for_hf ! electron 2 
   n = list_core_orb_for_hf(i_n)
   do i_i = 1, mo_num ! electron 1 
    i = i_i 
    do i_j = 1, mo_num ! electron 2 
     j = i_j 
     !                         2   1   2   1
     integrals_for_core_hf_pot(i_j,i_i,i_n,i_m) = get_two_e_integral(m,n,i,j,mo_integrals_map) 
    enddo
   enddo
  enddo
 enddo
END_PROVIDER 


subroutine f_HF_core_ab(r1,r2,integral_psi,two_bod)
 implicit none
 BEGIN_DOC
! f_HF_ab(X1,X2) = function f_{\Psi^B}(X_1,X_2) of equation (22) of paper J. Chem. Phys. 149, 194301 (2018)
! for alpha beta spins and an HF wave function
! < HF | wee_{\alpha\alpha} | HF > =  \int (X1,X2) f_HF_aa(X1,X2)
 END_DOC
 double precision, intent(in) :: r1(3), r2(3)
 double precision, intent(out):: integral_psi,two_bod
 integer :: i,j,m,n,i_m,i_n
 integer :: i_i,i_j
 double precision :: mo_two_e_integral
 double precision :: mos_array_r1(mo_num)
 double precision :: mos_array_r2(mo_num)
 double precision, allocatable  :: mos_array_core_r1(:)
 double precision, allocatable  :: mos_array_core_r2(:)
 double precision, allocatable  :: mos_array_core_hf_r1(:)
 double precision, allocatable  :: mos_array_core_hf_r2(:)
 double precision :: get_two_e_integral
 call give_all_mos_at_r(r1,mos_array_r1) 
 call give_all_mos_at_r(r2,mos_array_r2) 
 allocate(mos_array_core_r1( mo_num ) , mos_array_core_r2( mo_num ) )
 allocate(mos_array_core_hf_r1( n_core_orb_for_hf ) , mos_array_core_hf_r2( n_core_orb_for_hf ) )
 do i_m = 1, n_core_orb_for_hf
  mos_array_core_hf_r1(i_m) = mos_array_r1(list_core_orb_for_hf(i_m))
 enddo
 do i_m = 1, n_core_orb_for_hf
  mos_array_core_hf_r2(i_m) = mos_array_r2(list_core_orb_for_hf(i_m))
 enddo

 do i_m = 1, mo_num
  mos_array_core_r1(i_m) = mos_array_r1(i_m)
  mos_array_core_r2(i_m) = mos_array_r2(i_m)
 enddo


 integral_psi = 0.d0
 two_bod = 0.d0
 do m = 1, n_core_orb_for_hf ! electron 1 
  do n = 1, n_core_orb_for_hf ! electron 2 
   two_bod += mos_array_core_hf_r1(m) * mos_array_core_hf_r1(m) * mos_array_core_hf_r2(n) * mos_array_core_hf_r2(n) 
   do i = 1, mo_num
    do j = 1, mo_num
     !                                             2 1 2 1
     integral_psi +=  integrals_for_core_hf_pot(j,i,n,m)  & 
     * mos_array_core_r1(i) * mos_array_core_hf_r1(m)  & 
     * mos_array_core_r2(j) * mos_array_core_hf_r2(n)    
    enddo
   enddo
  enddo
 enddo
end


subroutine integral_f_HF_core_ab(r1,integral_psi)
 implicit none
 BEGIN_DOC
! f_HF_ab(X1,X2) = function f_{\Psi^B}(X_1,X_2) of equation (22) of paper J. Chem. Phys. 149, 194301 (2018)
! for alpha beta spins and an HF wave function
! < HF | wee_{\alpha\alpha} | HF > =  \int (X1,X2) f_HF_aa(X1,X2)
 END_DOC
 double precision, intent(in) :: r1(3)
 double precision, intent(out):: integral_psi
 integer :: i,j,m,n,i_m,i_n
 integer :: i_i,i_j
 double precision :: mo_two_e_integral
 double precision :: mos_array_r1(mo_num)
 double precision, allocatable  :: mos_array_core_r1(:)
 double precision, allocatable  :: mos_array_core_hf_r1(:)
 double precision :: get_two_e_integral
 call give_all_mos_at_r(r1,mos_array_r1) 
 allocate(mos_array_core_r1( mo_num ))
 allocate(mos_array_core_hf_r1( mo_num ) )
 do i_m = 1, n_core_orb_for_hf
  mos_array_core_hf_r1(i_m) = mos_array_r1(list_core_orb_for_hf(i_m))
 enddo
 do i_m = 1, mo_num
  mos_array_core_r1(i_m) = mos_array_r1(i_m)
 enddo

 integral_psi = 0.d0
 do m = 1, n_core_orb_for_hf! electron 1 
  do n = 1, n_core_orb_for_hf! electron 2 
   do i = 1, mo_num
     j = list_core(n)  
     !                                          2 1 2 1
     integral_psi +=  integrals_for_core_hf_pot(j,i,n,m)  & 
     * mos_array_core_r1(i) * mos_array_core_hf_r1(m) 
   enddo
  enddo
 enddo
end