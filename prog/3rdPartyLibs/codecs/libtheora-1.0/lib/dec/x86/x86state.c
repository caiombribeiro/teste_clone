/********************************************************************
 *                                                                  *
 * THIS FILE IS PART OF THE OggTheora SOFTWARE CODEC SOURCE CODE.   *
 * USE, DISTRIBUTION AND REPRODUCTION OF THIS LIBRARY SOURCE IS     *
 * GOVERNED BY A BSD-STYLE SOURCE LICENSE INCLUDED WITH THIS SOURCE *
 * IN 'COPYING'. PLEASE READ THESE TERMS BEFORE DISTRIBUTING.       *
 *                                                                  *
 * THE Theora SOURCE CODE IS COPYRIGHT (C) 2002-2007                *
 * by the Xiph.Org Foundation and contributors http://www.xiph.org/ *
 *                                                                  *
 ********************************************************************

  function:
      x86state.c 15427 2008-10-21 02:36:19Z xiphmont

 ********************************************************************/

#include "x86int.h"

#if defined(USE_ASM)

#include "../../cpu.c"

void oc_state_vtable_init_x86(oc_theora_state *_state){
  _state->cpu_flags=oc_cpu_flags_get();
  if(_state->cpu_flags&OC_CPU_X86_MMX){
    _state->opt_vtable.frag_recon_intra=oc_frag_recon_intra_mmx;
    _state->opt_vtable.frag_recon_inter=oc_frag_recon_inter_mmx;
    _state->opt_vtable.frag_recon_inter2=oc_frag_recon_inter2_mmx;
    _state->opt_vtable.state_frag_copy=oc_state_frag_copy_mmx;
    _state->opt_vtable.state_frag_recon=oc_state_frag_recon_mmx;
    _state->opt_vtable.state_loop_filter_frag_rows=
     oc_state_loop_filter_frag_rows_mmx;
    _state->opt_vtable.restore_fpu=oc_restore_fpu_mmx;
  }
  else oc_state_vtable_init_c(_state);
}
#endif
