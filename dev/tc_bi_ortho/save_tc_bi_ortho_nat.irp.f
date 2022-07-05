!program tc_natorb_bi_ortho
!  implicit none
!  BEGIN_DOC
!! TODO : Put the documentation of the program here
!  END_DOC
!  print *, 'Hello world'
!  my_grid_becke = .True.
!  my_n_pt_r_grid = 30
!  my_n_pt_a_grid = 50
!  read_wf = .True.
!  touch read_wf
!  touch  my_grid_becke my_n_pt_r_grid my_n_pt_a_grid
!  call save_tc_natorb
!end
!
!subroutine save_tc_natorb 
! implicit none
! print*,'Saving the natorbs '
! provide natorb_tc_leigvec_ao natorb_tc_reigvec_ao
! call ezfio_set_bi_ortho_mos_mo_l_coef(natorb_tc_leigvec_ao)
! call ezfio_set_bi_ortho_mos_mo_r_coef(natorb_tc_reigvec_ao)
! call save_ref_determinant_nstates_1
! call ezfio_set_determinants_read_wf(.False.)
!end
!
!subroutine save_ref_determinant_nstates_1
!  implicit none
!  use bitmasks
!  double precision               :: buffer(1,N_states)
!  buffer = 0.d0
!  buffer(1,1) = 1.d0
!  call save_wavefunction_general(1,1,ref_bitmask,1,buffer)                                                                                       
!end
!
!
! BEGIN_PROVIDER [ double precision, natorb_tc_reigvec_mo, (mo_num, mo_num)]
!&BEGIN_PROVIDER [ double precision, natorb_tc_leigvec_mo, (mo_num, mo_num)]
!&BEGIN_PROVIDER [ double precision, natorb_tc_eigval, (mo_num)]
! implicit none
! double precision, allocatable :: dm_tmp(:,:)
! integer :: i,j,k,n_real
! if(N_states.ne.2)then
!  print*,'N_states should be 2 !'
!  print*,'N_states = ',N_states
!  stop
! endif
! allocate( dm_tmp(mo_num,mo_num))
! dm_tmp(:,:) = -transition_matrix(:,:,1,2)
! print*,'dm_tmp'
! do i = 1, mo_num
!  write(*,'(100(F16.10,X))')-dm_tmp(:,i)
! enddo
!   call non_hrmt_real_im( mo_num, dm_tmp&
!                     , natorb_tc_leigvec_mo, natorb_tc_reigvec_mo& 
!                     , n_real, natorb_tc_eigval )
!double precision :: accu
! accu = 0.d0
! do i = 1, n_real
!  print*,'natorb_tc_eigval(i) = ',-natorb_tc_eigval(i)
!  accu += -natorb_tc_eigval(i)
! enddo
! print*,'accu = ',accu
! dm_tmp = 0.d0
! do i = 1, n_real
!  accu = 0.d0
!  do k = 1, mo_num
!   accu += natorb_tc_reigvec_mo(k,i) * natorb_tc_leigvec_mo(k,i)
!  enddo
!  accu = 1.d0/dsqrt(dabs(accu))
!  natorb_tc_reigvec_mo(:,i) *= accu
!  natorb_tc_leigvec_mo(:,i) *= accu
!  do j = 1, n_real
!   do k = 1, mo_num
!    dm_tmp(j,i) += natorb_tc_reigvec_mo(k,i) * natorb_tc_leigvec_mo(k,j)
!   enddo
!  enddo
! enddo
! double precision :: accu_d, accu_nd
! accu_d = 0.d0
! accu_nd = 0.d0
! do i = 1, mo_num
!  accu_d += dm_tmp(i,i)
!!  write(*,'(100(F16.10,X))')dm_tmp(:,i)
!  do j = 1, mo_num
!   if(i==j)cycle
!   accu_nd += dabs(dm_tmp(j,i))
!  enddo
! enddo
! print*,'Trace of the overlap between TC natural orbitals     ',accu_d
! print*,'L1 norm of extra diagonal elements of overlap matrix ',accu_nd
!
!
!END_PROVIDER 
!
! BEGIN_PROVIDER [ double precision, fock_diag_sorted_r_natorb, (mo_num, mo_num)]
!&BEGIN_PROVIDER [ double precision, fock_diag_sorted_l_natorb, (mo_num, mo_num)]
!&BEGIN_PROVIDER [ double precision, fock_diag_sorted_v_natorb, (mo_num)]
! implicit none
! integer ::i,j,k
! print*,'Diagonal elements of the Fock matrix before '
! do i = 1, mo_num
!  write(*,*)i,Fock_matrix_tc_mo_tot(i,i)
! enddo
! double precision, allocatable :: fock_diag(:)
! allocate(fock_diag(mo_num))
! fock_diag = 0.d0
! do i = 1, mo_num
!  fock_diag(i) = 0.d0
!  do j = 1, mo_num
!   do k = 1, mo_num
!    fock_diag(i) += natorb_tc_leigvec_mo(k,i) * Fock_matrix_tc_mo_tot(k,j) * natorb_tc_reigvec_mo(j,i) 
!   enddo
!  enddo
! enddo
! integer, allocatable :: iorder(:)
! allocate(iorder(mo_num))
! do i = 1, mo_num
!  iorder(i) = i
! enddo 
! call dsort(fock_diag,iorder,mo_num)
! print*,'Diagonal elements of the Fock matrix after '
! do i = 1, mo_num
!  write(*,*)i,fock_diag(i)
! enddo
! do i = 1, mo_num 
!  fock_diag_sorted_v_natorb(i) = natorb_tc_eigval(iorder(i))
!  do j = 1, mo_num
!   fock_diag_sorted_r_natorb(j,i) = natorb_tc_reigvec_mo(j,iorder(i))
!   fock_diag_sorted_l_natorb(j,i) = natorb_tc_leigvec_mo(j,iorder(i))
!  enddo
! enddo
!
!END_PROVIDER 
!
!
!
! BEGIN_PROVIDER [ double precision, natorb_tc_reigvec_ao, (ao_num, mo_num)]
!&BEGIN_PROVIDER [ double precision, natorb_tc_leigvec_ao, (ao_num, mo_num)]
!&BEGIN_PROVIDER [ double precision, overlap_natorb_tc_eigvec_ao, (mo_num, mo_num) ]
!
!  BEGIN_DOC
!  ! EIGENVECTORS OF FOCK MATRIX ON THE AO BASIS and their OVERLAP
!  !
!  ! THE OVERLAP SHOULD BE THE SAME AS overlap_natorb_tc_eigvec_mo
!  END_DOC
!
!  implicit none
!  integer                       :: i, j, k, q, p
!  double precision              :: accu, accu_d
!  double precision, allocatable :: tmp(:,:)
!
!
!!  ! MO_R x R
!  call dgemm( 'N', 'N', ao_num, mo_num, mo_num, 1.d0          &
!            , mo_r_coef, size(mo_r_coef, 1)                   &
!            , fock_diag_sorted_r_natorb, size(fock_diag_sorted_r_natorb, 1) &
!            , 0.d0, natorb_tc_reigvec_ao, size(natorb_tc_reigvec_ao, 1) )
!!
!  ! MO_L x L
!  call dgemm( 'N', 'N', ao_num, mo_num, mo_num, 1.d0          &
!            , mo_l_coef, size(mo_l_coef, 1)                   &
!            , fock_diag_sorted_l_natorb, size(fock_diag_sorted_l_natorb, 1) &
!            , 0.d0, natorb_tc_leigvec_ao, size(natorb_tc_leigvec_ao, 1) )
!
!
!  allocate( tmp(mo_num,ao_num) )
!
!  ! tmp <-- L.T x S_ao
!  call dgemm( "T", "N", mo_num, ao_num, ao_num, 1.d0                                           &
!            , natorb_tc_leigvec_ao, size(natorb_tc_leigvec_ao, 1), ao_overlap, size(ao_overlap, 1) &
!            , 0.d0, tmp, size(tmp, 1) )
!
!  ! S <-- tmp x R
!  call dgemm( "N", "N", mo_num, mo_num, ao_num, 1.d0                             &
!            , tmp, size(tmp, 1), natorb_tc_reigvec_ao, size(natorb_tc_reigvec_ao, 1) &
!            , 0.d0, overlap_natorb_tc_eigvec_ao, size(overlap_natorb_tc_eigvec_ao, 1) )
!
!  deallocate( tmp )
!
!  ! ---
!  double precision :: norm
!  do i = 1, mo_num
!   norm = 1.d0/dsqrt(dabs(overlap_natorb_tc_eigvec_ao(i,i)))
!   do j = 1, mo_num
!    natorb_tc_reigvec_ao(j,i) *= norm
!    natorb_tc_leigvec_ao(j,i) *= norm
!   enddo
!  enddo
!
!  allocate( tmp(mo_num,ao_num) )
!
!  ! tmp <-- L.T x S_ao
!  call dgemm( "T", "N", mo_num, ao_num, ao_num, 1.d0                                           &
!            , natorb_tc_leigvec_ao, size(natorb_tc_leigvec_ao, 1), ao_overlap, size(ao_overlap, 1) &
!            , 0.d0, tmp, size(tmp, 1) )
!
!  ! S <-- tmp x R
!  call dgemm( "N", "N", mo_num, mo_num, ao_num, 1.d0                             &
!            , tmp, size(tmp, 1), natorb_tc_reigvec_ao, size(natorb_tc_reigvec_ao, 1) &
!            , 0.d0, overlap_natorb_tc_eigvec_ao, size(overlap_natorb_tc_eigvec_ao, 1) )
!
!  deallocate( tmp )
!
!  accu_d = 0.d0
!  accu = 0.d0
!  do i = 1, mo_num
!    accu_d += overlap_natorb_tc_eigvec_ao(i,i)
!    do j = 1, mo_num
!      if(i==j)cycle
!      accu += dabs(overlap_natorb_tc_eigvec_ao(j,i))
!    enddo
!  enddo
!  print*,'Trace of the overlap_natorb_tc_eigvec_ao           = ',accu_d
!  print*,'mo_num                                             = ',mo_num
!  print*,'L1 norm of extra diagonal elements of overlap matrix ',accu
!  accu = accu / dble(mo_num**2)
!
!END_PROVIDER
