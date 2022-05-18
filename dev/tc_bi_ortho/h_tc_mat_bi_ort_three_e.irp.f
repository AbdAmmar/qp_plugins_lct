subroutine diag_htilde_three_body_ints_bi_ort(Nint, key_i, hthree)

  BEGIN_DOC
  !  diagonal element of htilde ONLY FOR THREE-BODY TERMS WITH BI ORTHONORMAL ORBITALS
  END_DOC

  use bitmasks

  implicit none
  integer,           intent(in) :: Nint
  integer(bit_kind), intent(in) :: key_i(Nint,2)
  double precision, intent(out) :: hthree
  integer                       :: occ(Nint*bit_kind_size,2)
  integer                       :: Ne(2),i,j,ii,jj,ispin,jspin,m,mm
  integer(bit_kind)             :: key_i_core(Nint,2)
  double precision              :: direct_int, exchange_int
  double precision              :: sym_3_e_int_from_6_idx_tensor,contrib
  double precision              :: three_e_diag_parrallel_spin

  if(core_tc_op)then
   do i = 1, Nint
    key_i_core(i,1) = xor(key_i(i,1),core_bitmask(i,1))
    key_i_core(i,2) = xor(key_i(i,2),core_bitmask(i,2))
   enddo
   call bitstring_to_list_ab(key_i_core,occ,Ne,Nint)
  else
   call bitstring_to_list_ab(key_i,occ,Ne,Nint)
  endif
  hthree = 0.d0

  if(Ne(1)+Ne(2).ge.3)then
!!  ! alpha/alpha/beta three-body
   do i = 1, Ne(1)
    ii = occ(i,1) 
    do j = i+1, Ne(1)
     jj = occ(j,1) 
     do m = 1, Ne(2)
      mm = occ(m,2) 
      direct_int = three_body_ints_bi_ort(mm,jj,ii,mm,jj,ii)
      exchange_int = three_body_ints_bi_ort(mm,jj,ii,mm,ii,jj)
      hthree += direct_int - exchange_int
     enddo
    enddo
   enddo
  
   ! beta/beta/alpha three-body
   do i = 1, Ne(2)
    ii = occ(i,2) 
    do j = i+1, Ne(2)
     jj = occ(j,2) 
     do m = 1, Ne(1)
      mm = occ(m,1) 
      direct_int = three_body_ints_bi_ort(mm,jj,ii,mm,jj,ii)
      exchange_int = three_body_ints_bi_ort(mm,jj,ii,mm,ii,jj)
      hthree += direct_int - exchange_int
     enddo
    enddo
   enddo

   ! alpha/alpha/alpha three-body
   do i = 1, Ne(1)
    ii = occ(i,1) ! 1
    do j = i+1, Ne(1)
     jj = occ(j,1) ! 2 
     do m = j+1, Ne(1)
      mm = occ(m,1) ! 3 
!      ref =  sym_3_e_int_from_6_idx_tensor(mm,jj,ii,mm,jj,ii) USES THE 6 IDX TENSOR 
      hthree += three_e_diag_parrallel_spin(mm,jj,ii) ! USES ONLY 3-IDX TENSORS
     enddo
    enddo
   enddo

   ! beta/beta/beta three-body
   do i = 1, Ne(2)
    ii = occ(i,2) ! 1
    do j = i+1, Ne(2)
     jj = occ(j,2) ! 2
     do m = j+1, Ne(2)
      mm = occ(m,2) ! 3
!      ref =  sym_3_e_int_from_6_idx_tensor(mm,jj,ii,mm,jj,ii) USES THE 6 IDX TENSOR 
      hthree += three_e_diag_parrallel_spin(mm,jj,ii) ! USES ONLY 3-IDX TENSORS
     enddo
    enddo
   enddo
  endif

end


subroutine single_htilde_three_body_ints_bi_ort(Nint, key_j, key_i, hthree)

  BEGIN_DOC
  ! <key_j | H_tilde | key_i> for single excitation ONLY FOR THREE-BODY TERMS WITH BI ORTHONORMAL ORBITALS
  !!
  !! WARNING !!
  ! 
  ! Non hermitian !!
  END_DOC

  use bitmasks

  implicit none
  integer,           intent(in) :: Nint
  integer(bit_kind), intent(in) :: key_j(Nint,2),key_i(Nint,2)
  double precision, intent(out) :: hthree
  integer                       :: occ(Nint*bit_kind_size,2)
  integer                       :: Ne(2),i,j,ii,jj,ispin,jspin,k,kk
  integer                       :: degree,exc(0:2,2,2)
  integer                       :: h1, p1, h2, p2, s1, s2
  double precision              :: direct_int,phase,exchange_int,three_e_single_parrallel_spin 
  double precision              :: contrib,sym_3_e_int_from_6_idx_tensor
  integer                       :: other_spin(2)
  integer(bit_kind)             :: key_j_core(Nint,2),key_i_core(Nint,2)

  other_spin(1) = 2
  other_spin(2) = 1


  hthree = 0.d0
  call get_excitation_degree(key_i,key_j,degree,Nint)
  if(degree.ne.1)then
   return
  endif
  if(core_tc_op)then
   do i = 1, Nint
    key_i_core(i,1) = xor(key_i(i,1),core_bitmask(i,1))
    key_i_core(i,2) = xor(key_i(i,2),core_bitmask(i,2))
    key_j_core(i,1) = xor(key_j(i,1),core_bitmask(i,1))
    key_j_core(i,2) = xor(key_j(i,2),core_bitmask(i,2))
   enddo
   call bitstring_to_list_ab(key_i_core, occ, Ne, Nint)
  else
   call bitstring_to_list_ab(key_i, occ, Ne, Nint)
  endif

  call get_single_excitation(key_i, key_j, exc, phase, Nint)
  call decode_exc(exc, 1, h1, p1, h2, p2, s1, s2)

   ! alpha/alpha/beta three-body
   if(Ne(1)+Ne(2).ge.3)then
     ! hole of spin s1 :: contribution from purely other spin 
     ispin = other_spin(s1)
     do i = 1, Ne(ispin)
      ii = occ(i,ispin) 
      do j = i+1, Ne(ispin)
       jj = occ(j,ispin) 
       !   is == ispin  in :::   s1 is is  s1 is is      s1 is is s1 is is
       !                       < h1 j  i | p1 j  i > - < h1 j  i | p1 i j >
       !                                                   
       direct_int   = three_body_ints_bi_ort(jj,ii,p1,jj,ii,h1)
       exchange_int = three_body_ints_bi_ort(jj,ii,p1,ii,jj,h1)
       hthree += direct_int - exchange_int
      enddo
     enddo
  
     ! hole of spin s1 :: contribution from mixed other spin / same spin
     do i = 1, Ne(ispin) ! other spin 
      ii = occ(i,ispin)  ! other spin 
      do j = 1, Ne(s1)   ! same spin 
       jj = occ(j,s1)    ! same spin 
       direct_int   = three_body_ints_bi_ort(jj,ii,p1,jj,ii,h1)
       exchange_int = three_body_ints_bi_ort(jj,ii,p1,h1,ii,jj) ! exchange the spin s1
       !              < h1 j  i | p1 j i > - < h1 j i | j p1 i >
       hthree += direct_int - exchange_int
      enddo
     enddo
!
     ! hole of spin s1 :: PURE SAME SPIN CONTRIBUTIONS !!!
     contrib = 0.D0
     do i = 1, Ne(s1)
      ii = occ(i,s1)
      do j = i+1, Ne(s1)
       jj = occ(j,s1)
!       ref = sym_3_e_int_from_6_idx_tensor(jj,ii,p1,jj,ii,h1)
       hthree += three_e_single_parrallel_spin(jj,ii,p1,h1) ! USES THE 4-IDX TENSOR 
      enddo
     enddo
   endif
  hthree  *= phase

end

subroutine double_htilde_three_body_ints_bi_ort(Nint, key_j, key_i, hthree)

  BEGIN_DOC
  ! <key_j | H_tilde | key_i> for double excitation ONLY FOR THREE-BODY TERMS  WITH BI ORTHONORMAL ORBITALS
  !!
  !! WARNING !!
  ! 
  ! Non hermitian !!
  END_DOC

  use bitmasks

  implicit none
  integer,           intent(in) :: Nint
  integer(bit_kind), intent(in) :: key_j(Nint,2),key_i(Nint,2)
  double precision, intent(out) :: hthree
  integer                       :: occ(Nint*bit_kind_size,2)
  integer                       :: Ne(2),i,j,ii,jj,ispin,jspin,m,mm
  integer                       :: degree,exc(0:2,2,2)
  integer                       :: h1, p1, h2, p2, s1, s2
  double precision              :: phase
  integer                       :: other_spin(2)
  integer(bit_kind)             :: key_i_core(Nint,2)
  double precision              :: integral,integral_exch,sym_3_e_int_from_6_idx_tensor

  other_spin(1) = 2
  other_spin(2) = 1

  call get_excitation_degree(key_i, key_j, degree, Nint)

  hthree = 0.d0

  if(degree.ne.2)then
   return
  endif

  if(core_tc_op)then
   do i = 1, Nint
    key_i_core(i,1) = xor(key_i(i,1),core_bitmask(i,1))
    key_i_core(i,2) = xor(key_i(i,2),core_bitmask(i,2))
   enddo
   call bitstring_to_list_ab(key_i_core, occ, Ne, Nint)
  else
   call bitstring_to_list_ab(key_i, occ, Ne, Nint)
  endif
  call get_double_excitation(key_i, key_j, exc, phase, Nint)
  call decode_exc(exc, 2, h1, p1, h2, p2, s1, s2)

    
    if(Ne(1)+Ne(2).ge.3)then
     if(s1==s2)then ! same spin excitation 
      ispin = other_spin(s1)
      do m = 1, Ne(ispin) ! direct(other_spin) - exchange(s1)
       mm = occ(m,ispin)
       hthree += three_body_ints_bi_ort(mm,p1,p1,mm,h2,h1) & 
               - three_body_ints_bi_ort(mm,p1,p1,mm,h1,h2)
      enddo
      double precision :: contrib, ref, new, three_e_double_parrallel_spin
      do m = 1, Ne(s1) ! pure contribution from s1 
       mm = occ(m,s1)
       new = three_e_double_parrallel_spin(mm,p2,h2,p1,h1)
       ref = sym_3_e_int_from_6_idx_tensor(mm,p1,p1,mm,h2,h1)
       if(dabs(ref - new).gt.1.d-10.and.dabs(ref).gt.1.d-10)then
        print*,mm,p2,h2,p1,h1
        print*,ref,new,dabs(ref - new)
       endif
       hthree += new
      enddo 
     else ! different spin excitation 
       do m = 1, Ne(s1)
        mm = occ(m,s1) ! 
        hthree += three_body_ints_bi_ort(mm,p1,p1,mm,h2,h1) & 
                - three_body_ints_bi_ort(mm,p1,p1,h1,h2,mm) ! exchange h1--mm
       enddo
       do m = 1, Ne(s2)
        mm = occ(m,s2) ! 
        hthree += three_body_ints_bi_ort(mm,p1,p1,mm,h2,h1) & 
                - three_body_ints_bi_ort(mm,p1,p1,h2,mm,h1) ! exchange h2--mm 
       enddo
     endif
    endif
  hthree  *= phase
 end