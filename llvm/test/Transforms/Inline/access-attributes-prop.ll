; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes
; RUN: opt -S -passes=inline %s | FileCheck %s
; RUN: opt -S -passes='cgscc(inline)' %s | FileCheck %s
; RUN: opt -S -passes='module-inline' %s | FileCheck %s

declare void @bar1(ptr %p)
declare void @bar2(ptr %p, ptr %p2)
declare void @bar3(ptr writable %p)
declare void @bar4(ptr byval([4 x i32]) %p)
define dso_local void @foo1_rdonly(ptr readonly %p) {
; CHECK-LABEL: define {{[^@]+}}@foo1_rdonly
; CHECK-SAME: (ptr readonly [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr %p)
  ret void
}

define dso_local void @foo1(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@foo1
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr %p)
  ret void
}

define dso_local void @foo1_writable(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@foo1_writable
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr writable [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr writable %p)
  ret void
}

define dso_local void @foo3_writable(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@foo3_writable
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar3(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar3(ptr %p)
  ret void
}


define dso_local void @foo1_bar_aligned64_deref512(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@foo1_bar_aligned64_deref512
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr align 64 dereferenceable(512) [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr align 64 dereferenceable(512) %p)
  ret void
}

define dso_local void @foo1_bar_aligned512_deref_or_null512(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@foo1_bar_aligned512_deref_or_null512
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr align 512 dereferenceable_or_null(512) [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr align 512 dereferenceable_or_null(512) %p)
  ret void
}

define dso_local void @foo2(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@foo2
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar2(ptr %p, ptr %p)
  ret void
}

define dso_local void @foo2_2(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@foo2_2
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr [[P2]], ptr [[P2]])
; CHECK-NEXT:    ret void
;
  call void @bar2(ptr %p2, ptr %p2)
  ret void
}

define dso_local void @foo2_3(ptr %p, ptr readnone %p2) {
; CHECK-LABEL: define {{[^@]+}}@foo2_3
; CHECK-SAME: (ptr [[P:%.*]], ptr readnone [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[P2]])
; CHECK-NEXT:    ret void
;
  call void @bar2(ptr %p, ptr %p2)
  ret void
}

define dso_local void @buz1_wronly(ptr %p) writeonly {
; CHECK: Function Attrs: memory(write)
; CHECK-LABEL: define {{[^@]+}}@buz1_wronly
; CHECK-SAME: (ptr [[P:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr %p)
  ret void
}

define dso_local void @buz1(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@buz1
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr %p)
  ret void
}

define dso_local void @buz1_wronly_fail_alloca(ptr %p) writeonly {
; CHECK: Function Attrs: memory(write)
; CHECK-LABEL: define {{[^@]+}}@buz1_wronly_fail_alloca
; CHECK-SAME: (ptr [[P:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A]])
; CHECK-NEXT:    ret void
;
  %a = alloca i32, align 4
  call void @bar2(ptr %p, ptr %a)
  ret void
}

define dso_local void @buz1_fail_alloca(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@buz1_fail_alloca
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A]])
; CHECK-NEXT:    ret void
;
  %a = alloca i32, align 4
  call void @bar2(ptr %p, ptr %a)
  ret void
}

define dso_local void @buz1_wronly_partially_okay_alloca(ptr %p) writeonly {
; CHECK: Function Attrs: memory(write)
; CHECK-LABEL: define {{[^@]+}}@buz1_wronly_partially_okay_alloca
; CHECK-SAME: (ptr [[P:%.*]]) #[[ATTR0]] {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr %p)
  %a = alloca i32, align 4
  call void @bar2(ptr %p, ptr %a)
  ret void
}

define dso_local void @buz1_partially_okay_alloca(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@buz1_partially_okay_alloca
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    [[A:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A]])
; CHECK-NEXT:    ret void
;
  call void @bar1(ptr %p)
  %a = alloca i32, align 4
  call void @bar2(ptr %p, ptr %a)
  ret void
}

define dso_local void @foo2_through_obj(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@foo2_through_obj
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[PP:%.*]] = getelementptr i8, ptr [[P]], i64 9
; CHECK-NEXT:    [[P2P:%.*]] = getelementptr i8, ptr [[P2]], i64 123
; CHECK-NEXT:    call void @bar2(ptr [[P2P]], ptr [[PP]])
; CHECK-NEXT:    ret void
;
  %pp = getelementptr i8, ptr %p, i64 9
  %p2p = getelementptr i8, ptr %p2, i64 123
  call void @bar2(ptr %p2p, ptr %pp)
  ret void
}

define dso_local void @foo_byval_readonly(ptr readonly %p) {
; CHECK-LABEL: define {{[^@]+}}@foo_byval_readonly
; CHECK-SAME: (ptr readonly [[P:%.*]]) {
; CHECK-NEXT:    call void @bar4(ptr byval([4 x i32]) [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar4(ptr byval([4 x i32]) %p)
  ret void
}

define void @prop_param_func_decl(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_func_decl
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr readonly [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1_rdonly(ptr %p)
  ret void
}

define void @prop_param_callbase_def(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr readonly [[P]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr readonly %p)
  call void @bar1(ptr %p)
  ret void
}

define void @prop_param_callbase_def_2x(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_2x
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr readonly [[P]], ptr readonly [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo2(ptr readonly %p, ptr %p)
  ret void
}

define void @prop_param_callbase_def_2x_2(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_2x_2
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[PP_I:%.*]] = getelementptr i8, ptr [[P]], i64 9
; CHECK-NEXT:    [[P2P_I:%.*]] = getelementptr i8, ptr [[P2]], i64 123
; CHECK-NEXT:    call void @bar2(ptr [[P2P_I]], ptr readonly [[PP_I]])
; CHECK-NEXT:    ret void
;
  call void @foo2_through_obj(ptr readonly %p, ptr writeonly %p2)
  ret void
}

define void @prop_param_callbase_def_2x_incompat(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_2x_incompat
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    [[PP_I:%.*]] = getelementptr i8, ptr [[P]], i64 9
; CHECK-NEXT:    [[P2P_I:%.*]] = getelementptr i8, ptr [[P]], i64 123
; CHECK-NEXT:    call void @bar2(ptr readonly [[P2P_I]], ptr readnone [[PP_I]])
; CHECK-NEXT:    ret void
;
  call void @foo2_through_obj(ptr readnone %p, ptr readonly %p)
  ret void
}

define void @prop_param_callbase_def_2x_incompat_2(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_2x_incompat_2
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr readonly [[P]], ptr readonly [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo2(ptr readonly %p, ptr readnone %p)
  ret void
}

define void @prop_param_callbase_def_2x_incompat_3(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_2x_incompat_3
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr readnone [[P]], ptr readnone [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo2_2(ptr readonly %p, ptr readnone %p)
  ret void
}

define void @prop_param_callbase_def_1x_partial(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_1x_partial
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr readonly [[P]], ptr readonly [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo2(ptr readonly %p, ptr %p)
  ret void
}

define void @prop_param_callbase_def_1x_partial_2(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_1x_partial_2
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo2_2(ptr readonly %p, ptr %p)
  ret void
}

define void @prop_param_callbase_def_1x_partial_3(ptr %p, ptr %p2) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_callbase_def_1x_partial_3
; CHECK-SAME: (ptr [[P:%.*]], ptr [[P2:%.*]]) {
; CHECK-NEXT:    call void @bar2(ptr readonly [[P]], ptr readnone [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo2_3(ptr readonly %p, ptr %p)
  ret void
}

define void @prop_deref(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_deref
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr dereferenceable(16) %p)
  ret void
}

define void @prop_deref_or_null(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_deref_or_null
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr dereferenceable_or_null(256) %p)
  ret void
}

define void @prop_param_nonnull_and_align(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_nonnull_and_align
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr nonnull align 32 %p)
  ret void
}

define void @prop_param_deref_align_no_update(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_deref_align_no_update
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr align 64 dereferenceable(512) [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1_bar_aligned64_deref512(ptr align 4 dereferenceable(64) %p)
  ret void
}

define void @prop_param_deref_align_update(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_deref_align_update
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr align 64 dereferenceable(512) [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1_bar_aligned64_deref512(ptr align 128 dereferenceable(1024) %p)
  ret void
}

define void @prop_param_deref_or_null_update(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_deref_or_null_update
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr align 512 dereferenceable_or_null(512) [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1_bar_aligned512_deref_or_null512(ptr dereferenceable_or_null(1024) %p)
  ret void
}

define void @prop_param_deref_or_null_no_update(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_param_deref_or_null_no_update
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr align 512 dereferenceable_or_null(512) [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1_bar_aligned512_deref_or_null512(ptr dereferenceable_or_null(32) %p)
  ret void
}

define void @prop_fn_decl(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_fn_decl
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @buz1_wronly(ptr %p)
  call void @bar1(ptr %p)
  ret void
}

define void @prop_cb_def_wr(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_wr
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @buz1(ptr %p) writeonly
  call void @bar1(ptr %p)
  ret void
}

define void @prop_fn_decl_fail_alloca(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_fn_decl_fail_alloca
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    [[A_I:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A_I]])
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @buz1_wronly_fail_alloca(ptr %p)
  call void @bar1(ptr %p)
  ret void
}

define void @prop_cb_def_wr_fail_alloca(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_wr_fail_alloca
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    [[A_I:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A_I]])
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @buz1_fail_alloca(ptr %p) writeonly
  call void @bar1(ptr %p)
  ret void
}

define void @prop_fn_decl_partially_okay_alloca(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_fn_decl_partially_okay_alloca
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    [[A_I:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A_I]])
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @buz1_wronly_partially_okay_alloca(ptr %p)
  call void @bar1(ptr %p)
  ret void
}

define void @prop_cb_def_wr_partially_okay_alloca(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_wr_partially_okay_alloca
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    [[A_I:%.*]] = alloca i32, align 4
; CHECK-NEXT:    call void @llvm.lifetime.start.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    call void @bar2(ptr [[P]], ptr [[A_I]])
; CHECK-NEXT:    call void @llvm.lifetime.end.p0(i64 4, ptr [[A_I]])
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @buz1_partially_okay_alloca(ptr %p) writeonly
  call void @bar1(ptr %p)
  ret void
}

define void @prop_cb_def_readonly(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_readonly
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) readonly
  ret void
}

define void @prop_cb_def_readnone(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_readnone
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) readnone
  ret void
}

define void @prop_cb_def_argmem_readonly_fail(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_argmem_readonly_fail
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) memory(argmem:read)
  ret void
}

define void @prop_cb_def_inaccessible_none(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_inaccessible_none
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) memory(inaccessiblemem:none)
  ret void
}

define void @prop_cb_def_inaccessible_none_argmem_none(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_inaccessible_none_argmem_none
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) memory(inaccessiblemem:none, argmem:none)
  ret void
}

define void @prop_cb_def_willreturn(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_willreturn
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) willreturn
  ret void
}

define void @prop_cb_def_mustprogress(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_cb_def_mustprogress
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1(ptr %p) mustprogress
  ret void
}

define void @prop_no_conflict_writable(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_no_conflict_writable
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar1(ptr readonly [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo1_writable(ptr readonly %p)
  ret void
}


define void @prop_no_conflict_writable2(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_no_conflict_writable2
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar3(ptr readnone [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo3_writable(ptr readnone %p)
  ret void
}

define void @prop_byval_readonly(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_byval_readonly
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar4(ptr byval([4 x i32]) [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo_byval_readonly(ptr %p)
  ret void
}

define ptr @caller_bad_param_prop(ptr %p1, ptr %p2, i64 %x) {
; CHECK-LABEL: define {{[^@]+}}@caller_bad_param_prop
; CHECK-SAME: (ptr [[P1:%.*]], ptr [[P2:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:    [[TMP1:%.*]] = call ptr [[P1]](i64 [[X]], ptr [[P2]])
; CHECK-NEXT:    ret ptr [[TMP1]]
;
  %1 = call ptr %p1(i64 %x, ptr %p2)
  %2 = call ptr @callee_bad_param_prop(ptr %1)
  ret ptr %2
}

define ptr @callee_bad_param_prop(ptr readonly %x) {
; CHECK-LABEL: define {{[^@]+}}@callee_bad_param_prop
; CHECK-SAME: (ptr readonly [[X:%.*]]) {
; CHECK-NEXT:    [[R:%.*]] = tail call ptr @llvm.ptrmask.p0.i64(ptr [[X]], i64 -1)
; CHECK-NEXT:    ret ptr [[R]]
;
  %r = tail call ptr @llvm.ptrmask(ptr %x, i64 -1)
  ret ptr %r
}

define dso_local void @foo_byval_readonly2(ptr readonly %p) {
; CHECK-LABEL: define {{[^@]+}}@foo_byval_readonly2
; CHECK-SAME: (ptr readonly [[P:%.*]]) {
; CHECK-NEXT:    call void @bar4(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @bar4(ptr %p)
  ret void
}

define void @prop_byval_readonly2(ptr %p) {
; CHECK-LABEL: define {{[^@]+}}@prop_byval_readonly2
; CHECK-SAME: (ptr [[P:%.*]]) {
; CHECK-NEXT:    call void @bar4(ptr [[P]])
; CHECK-NEXT:    ret void
;
  call void @foo_byval_readonly2(ptr %p)
  ret void
}
