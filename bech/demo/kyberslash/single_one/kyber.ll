; ModuleID = 'kyber.ll'
source_filename = "kyber.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.poly = type { [256 x i16] }
%struct.smack_value = type { i8* }

; Function Attrs: noinline nounwind uwtable
define dso_local void @poly_tomsg(i8* %0, %struct.poly* %1) #0 !dbg !14 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !31, metadata !DIExpression()), !dbg !32
  call void @llvm.dbg.value(metadata %struct.poly* %1, metadata !33, metadata !DIExpression()), !dbg !32
  %3 = getelementptr inbounds %struct.poly, %struct.poly* %1, i32 0, i32 0, !dbg !34
  %4 = getelementptr inbounds [256 x i16], [256 x i16]* %3, i64 0, i64 0, !dbg !35
  %5 = load i16, i16* %4, align 2, !dbg !35
  %6 = sext i16 %5 to i32, !dbg !35
  call void @llvm.dbg.value(metadata i32 %6, metadata !36, metadata !DIExpression()), !dbg !32
  %7 = sdiv i32 %6, 2, !dbg !37
  call void @llvm.dbg.value(metadata i32 %7, metadata !38, metadata !DIExpression()), !dbg !32
  call void @llvm.dbg.value(metadata i32 0, metadata !39, metadata !DIExpression()), !dbg !32
  br label %8, !dbg !41

8:                                                ; preds = %45, %2
  %.01 = phi i32 [ 0, %2 ], [ %46, %45 ], !dbg !43
  call void @llvm.dbg.value(metadata i32 %.01, metadata !39, metadata !DIExpression()), !dbg !32
  %9 = icmp ult i32 %.01, 32, !dbg !44
  br i1 %9, label %10, label %47, !dbg !46

10:                                               ; preds = %8
  %11 = zext i32 %.01 to i64, !dbg !47
  %12 = getelementptr inbounds i8, i8* %0, i64 %11, !dbg !47
  store i8 0, i8* %12, align 1, !dbg !49
  call void @llvm.dbg.value(metadata i32 0, metadata !50, metadata !DIExpression()), !dbg !32
  br label %13, !dbg !51

13:                                               ; preds = %42, %10
  %.0 = phi i32 [ 0, %10 ], [ %43, %42 ], !dbg !53
  call void @llvm.dbg.value(metadata i32 %.0, metadata !50, metadata !DIExpression()), !dbg !32
  %14 = icmp ult i32 %.0, 8, !dbg !54
  br i1 %14, label %15, label %44, !dbg !56

15:                                               ; preds = %13
  %16 = getelementptr inbounds %struct.poly, %struct.poly* %1, i32 0, i32 0, !dbg !57
  %17 = mul i32 8, %.01, !dbg !59
  %18 = add i32 %17, %.0, !dbg !60
  %19 = zext i32 %18 to i64, !dbg !61
  %20 = getelementptr inbounds [256 x i16], [256 x i16]* %16, i64 0, i64 %19, !dbg !61
  %21 = load i16, i16* %20, align 2, !dbg !61
  call void @llvm.dbg.value(metadata i16 %21, metadata !62, metadata !DIExpression()), !dbg !32
  %22 = sext i16 %21 to i32, !dbg !66
  %23 = ashr i32 %22, 15, !dbg !67
  %24 = and i32 %23, 3329, !dbg !68
  %25 = zext i16 %21 to i32, !dbg !69
  %26 = add nsw i32 %25, %24, !dbg !69
  %27 = trunc i32 %26 to i16, !dbg !69
  call void @llvm.dbg.value(metadata i16 %27, metadata !62, metadata !DIExpression()), !dbg !32
  %28 = zext i16 %27 to i32, !dbg !70
  %29 = shl i32 %28, 1, !dbg !71
  %30 = add nsw i32 %29, 1664, !dbg !72
  %31 = sdiv i32 %30, 3329, !dbg !73
  %32 = and i32 %31, 1, !dbg !74
  %33 = trunc i32 %32 to i16, !dbg !75
  call void @llvm.dbg.value(metadata i16 %33, metadata !62, metadata !DIExpression()), !dbg !32
  %34 = zext i16 %33 to i32, !dbg !76
  %35 = shl i32 %34, %.0, !dbg !77
  %36 = zext i32 %.01 to i64, !dbg !78
  %37 = getelementptr inbounds i8, i8* %0, i64 %36, !dbg !78
  %38 = load i8, i8* %37, align 1, !dbg !79
  %39 = zext i8 %38 to i32, !dbg !79
  %40 = or i32 %39, %35, !dbg !79
  %41 = trunc i32 %40 to i8, !dbg !79
  store i8 %41, i8* %37, align 1, !dbg !79
  br label %42, !dbg !80

42:                                               ; preds = %15
  %43 = add i32 %.0, 1, !dbg !81
  call void @llvm.dbg.value(metadata i32 %43, metadata !50, metadata !DIExpression()), !dbg !32
  br label %13, !dbg !82, !llvm.loop !83

44:                                               ; preds = %13
  br label %45, !dbg !86

45:                                               ; preds = %44
  %46 = add i32 %.01, 1, !dbg !87
  call void @llvm.dbg.value(metadata i32 %46, metadata !39, metadata !DIExpression()), !dbg !32
  br label %8, !dbg !88, !llvm.loop !89

47:                                               ; preds = %8
  ret void, !dbg !91
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind uwtable
define dso_local void @poly_tomsg_wrapper(i8* %0, %struct.poly* %1) #0 !dbg !92 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !93, metadata !DIExpression()), !dbg !94
  call void @llvm.dbg.value(metadata %struct.poly* %1, metadata !95, metadata !DIExpression()), !dbg !94
  %3 = call %struct.smack_value* (i8*, ...) bitcast (%struct.smack_value* (...)* @__SMACK_value to %struct.smack_value* (i8*, ...)*)(i8* %0), !dbg !96
  call void @public_in(%struct.smack_value* %3), !dbg !97
  %4 = call %struct.smack_value* (%struct.poly*, ...) bitcast (%struct.smack_value* (...)* @__SMACK_value to %struct.smack_value* (%struct.poly*, ...)*)(%struct.poly* %1), !dbg !98
  call void @public_in(%struct.smack_value* %4), !dbg !99
  call void @llvm.dbg.value(metadata i32 0, metadata !100, metadata !DIExpression()), !dbg !102
  br label %5, !dbg !103

5:                                                ; preds = %13, %2
  %.0 = phi i32 [ 0, %2 ], [ %14, %13 ], !dbg !102
  call void @llvm.dbg.value(metadata i32 %.0, metadata !100, metadata !DIExpression()), !dbg !102
  %6 = icmp ult i32 %.0, 256, !dbg !104
  br i1 %6, label %7, label %15, !dbg !106

7:                                                ; preds = %5
  %8 = getelementptr inbounds %struct.poly, %struct.poly* %1, i32 0, i32 0, !dbg !107
  %9 = zext i32 %.0 to i64, !dbg !109
  %10 = getelementptr inbounds [256 x i16], [256 x i16]* %8, i64 0, i64 %9, !dbg !109
  %11 = load i16, i16* %10, align 2, !dbg !109
  %12 = sext i16 %11 to i32, !dbg !110
  call void @vfct_taintseed(i32 %12), !dbg !111
  br label %13, !dbg !112

13:                                               ; preds = %7
  %14 = add i32 %.0, 1, !dbg !113
  call void @llvm.dbg.value(metadata i32 %14, metadata !100, metadata !DIExpression()), !dbg !102
  br label %5, !dbg !114, !llvm.loop !115

15:                                               ; preds = %5
  call void @poly_tomsg(i8* %0, %struct.poly* %1), !dbg !117
  ret void, !dbg !118
}

declare dso_local void @public_in(%struct.smack_value*) #2

declare dso_local %struct.smack_value* @__SMACK_value(...) #2

declare dso_local void @vfct_taintseed(i32) #2

; Function Attrs: noinline nounwind uwtable
define dso_local void @kyber_wrapper_t() #0 !dbg !119 {
  %1 = alloca [32 x i8], align 16
  %2 = alloca %struct.poly, align 2
  call void @llvm.dbg.declare(metadata [32 x i8]* %1, metadata !122, metadata !DIExpression()), !dbg !126
  call void @llvm.dbg.declare(metadata %struct.poly* %2, metadata !127, metadata !DIExpression()), !dbg !128
  call void @llvm.dbg.value(metadata i32 0, metadata !129, metadata !DIExpression()), !dbg !131
  br label %3, !dbg !132

3:                                                ; preds = %11, %0
  %.0 = phi i32 [ 0, %0 ], [ %12, %11 ], !dbg !131
  call void @llvm.dbg.value(metadata i32 %.0, metadata !129, metadata !DIExpression()), !dbg !131
  %4 = icmp ult i32 %.0, 256, !dbg !133
  br i1 %4, label %5, label %13, !dbg !135

5:                                                ; preds = %3
  %6 = call i32 @getint32(), !dbg !136
  %7 = trunc i32 %6 to i16, !dbg !138
  %8 = getelementptr inbounds %struct.poly, %struct.poly* %2, i32 0, i32 0, !dbg !139
  %9 = zext i32 %.0 to i64, !dbg !140
  %10 = getelementptr inbounds [256 x i16], [256 x i16]* %8, i64 0, i64 %9, !dbg !140
  store i16 %7, i16* %10, align 2, !dbg !141
  br label %11, !dbg !142

11:                                               ; preds = %5
  %12 = add i32 %.0, 1, !dbg !143
  call void @llvm.dbg.value(metadata i32 %12, metadata !129, metadata !DIExpression()), !dbg !131
  br label %3, !dbg !144, !llvm.loop !145

13:                                               ; preds = %3
  %14 = getelementptr inbounds [32 x i8], [32 x i8]* %1, i64 0, i64 0, !dbg !147
  call void @poly_tomsg_wrapper(i8* %14, %struct.poly* %2), !dbg !148
  ret void, !dbg !149
}

declare dso_local i32 @getint32() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { noinline nounwind uwtable "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #2 = { "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!10, !11, !12}
!llvm.ident = !{!13}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "Ubuntu clang version 12.0.1-++20211029101322+fed41342a82f-1~exp1~20211029221816.4", isOptimized: false, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "kyber.c", directory: "/home/user/CT_Prover/bech/demo/kyberslash")
!2 = !{}
!3 = !{!4, !9}
!4 = !DIDerivedType(tag: DW_TAG_typedef, name: "int16_t", file: !5, line: 25, baseType: !6)
!5 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-intn.h", directory: "")
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int16_t", file: !7, line: 39, baseType: !8)
!7 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/types.h", directory: "")
!8 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!9 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!10 = !{i32 7, !"Dwarf Version", i32 4}
!11 = !{i32 2, !"Debug Info Version", i32 3}
!12 = !{i32 1, !"wchar_size", i32 4}
!13 = !{!"Ubuntu clang version 12.0.1-++20211029101322+fed41342a82f-1~exp1~20211029221816.4"}
!14 = distinct !DISubprogram(name: "poly_tomsg", scope: !1, file: !1, line: 25, type: !15, scopeLine: 26, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!15 = !DISubroutineType(types: !16)
!16 = !{null, !17, !22}
!17 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !18, size: 64)
!18 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint8_t", file: !19, line: 24, baseType: !20)
!19 = !DIFile(filename: "/usr/include/x86_64-linux-gnu/bits/stdint-uintn.h", directory: "")
!20 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint8_t", file: !7, line: 38, baseType: !21)
!21 = !DIBasicType(name: "unsigned char", size: 8, encoding: DW_ATE_unsigned_char)
!22 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !23, size: 64)
!23 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !24)
!24 = !DIDerivedType(tag: DW_TAG_typedef, name: "poly", file: !1, line: 14, baseType: !25)
!25 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !1, line: 12, size: 4096, elements: !26)
!26 = !{!27}
!27 = !DIDerivedType(tag: DW_TAG_member, name: "coeffs", scope: !25, file: !1, line: 13, baseType: !28, size: 4096)
!28 = !DICompositeType(tag: DW_TAG_array_type, baseType: !4, size: 4096, elements: !29)
!29 = !{!30}
!30 = !DISubrange(count: 256)
!31 = !DILocalVariable(name: "msg", arg: 1, scope: !14, file: !1, line: 25, type: !17)
!32 = !DILocation(line: 0, scope: !14)
!33 = !DILocalVariable(name: "a", arg: 2, scope: !14, file: !1, line: 25, type: !22)
!34 = !DILocation(line: 30, column: 19, scope: !14)
!35 = !DILocation(line: 30, column: 16, scope: !14)
!36 = !DILocalVariable(name: "this", scope: !14, file: !1, line: 30, type: !9)
!37 = !DILocation(line: 31, column: 20, scope: !14)
!38 = !DILocalVariable(name: "huh", scope: !14, file: !1, line: 31, type: !9)
!39 = !DILocalVariable(name: "i", scope: !14, file: !1, line: 27, type: !40)
!40 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!41 = !DILocation(line: 33, column: 9, scope: !42)
!42 = distinct !DILexicalBlock(scope: !14, file: !1, line: 33, column: 5)
!43 = !DILocation(line: 0, scope: !42)
!44 = !DILocation(line: 33, column: 14, scope: !45)
!45 = distinct !DILexicalBlock(scope: !42, file: !1, line: 33, column: 5)
!46 = !DILocation(line: 33, column: 5, scope: !42)
!47 = !DILocation(line: 34, column: 9, scope: !48)
!48 = distinct !DILexicalBlock(scope: !45, file: !1, line: 33, column: 30)
!49 = !DILocation(line: 34, column: 16, scope: !48)
!50 = !DILocalVariable(name: "j", scope: !14, file: !1, line: 27, type: !40)
!51 = !DILocation(line: 35, column: 13, scope: !52)
!52 = distinct !DILexicalBlock(scope: !48, file: !1, line: 35, column: 9)
!53 = !DILocation(line: 0, scope: !52)
!54 = !DILocation(line: 35, column: 18, scope: !55)
!55 = distinct !DILexicalBlock(scope: !52, file: !1, line: 35, column: 9)
!56 = !DILocation(line: 35, column: 9, scope: !52)
!57 = !DILocation(line: 36, column: 21, scope: !58)
!58 = distinct !DILexicalBlock(scope: !55, file: !1, line: 35, column: 26)
!59 = !DILocation(line: 36, column: 29, scope: !58)
!60 = !DILocation(line: 36, column: 31, scope: !58)
!61 = !DILocation(line: 36, column: 18, scope: !58)
!62 = !DILocalVariable(name: "t", scope: !14, file: !1, line: 28, type: !63)
!63 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !19, line: 25, baseType: !64)
!64 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !7, line: 40, baseType: !65)
!65 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!66 = !DILocation(line: 37, column: 19, scope: !58)
!67 = !DILocation(line: 37, column: 30, scope: !58)
!68 = !DILocation(line: 37, column: 37, scope: !58)
!69 = !DILocation(line: 37, column: 15, scope: !58)
!70 = !DILocation(line: 38, column: 21, scope: !58)
!71 = !DILocation(line: 38, column: 23, scope: !58)
!72 = !DILocation(line: 38, column: 29, scope: !58)
!73 = !DILocation(line: 38, column: 41, scope: !58)
!74 = !DILocation(line: 38, column: 51, scope: !58)
!75 = !DILocation(line: 38, column: 18, scope: !58)
!76 = !DILocation(line: 39, column: 23, scope: !58)
!77 = !DILocation(line: 39, column: 25, scope: !58)
!78 = !DILocation(line: 39, column: 13, scope: !58)
!79 = !DILocation(line: 39, column: 20, scope: !58)
!80 = !DILocation(line: 40, column: 9, scope: !58)
!81 = !DILocation(line: 35, column: 22, scope: !55)
!82 = !DILocation(line: 35, column: 9, scope: !55)
!83 = distinct !{!83, !56, !84, !85}
!84 = !DILocation(line: 40, column: 9, scope: !52)
!85 = !{!"llvm.loop.mustprogress"}
!86 = !DILocation(line: 41, column: 5, scope: !48)
!87 = !DILocation(line: 33, column: 26, scope: !45)
!88 = !DILocation(line: 33, column: 5, scope: !45)
!89 = distinct !{!89, !46, !90, !85}
!90 = !DILocation(line: 41, column: 5, scope: !42)
!91 = !DILocation(line: 42, column: 1, scope: !14)
!92 = distinct !DISubprogram(name: "poly_tomsg_wrapper", scope: !1, file: !1, line: 44, type: !15, scopeLine: 45, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!93 = !DILocalVariable(name: "msg", arg: 1, scope: !92, file: !1, line: 44, type: !17)
!94 = !DILocation(line: 0, scope: !92)
!95 = !DILocalVariable(name: "a", arg: 2, scope: !92, file: !1, line: 44, type: !22)
!96 = !DILocation(line: 46, column: 15, scope: !92)
!97 = !DILocation(line: 46, column: 5, scope: !92)
!98 = !DILocation(line: 47, column: 15, scope: !92)
!99 = !DILocation(line: 47, column: 5, scope: !92)
!100 = !DILocalVariable(name: "i", scope: !101, file: !1, line: 48, type: !40)
!101 = distinct !DILexicalBlock(scope: !92, file: !1, line: 48, column: 5)
!102 = !DILocation(line: 0, scope: !101)
!103 = !DILocation(line: 48, column: 10, scope: !101)
!104 = !DILocation(line: 48, column: 32, scope: !105)
!105 = distinct !DILexicalBlock(scope: !101, file: !1, line: 48, column: 5)
!106 = !DILocation(line: 48, column: 5, scope: !101)
!107 = !DILocation(line: 49, column: 32, scope: !108)
!108 = distinct !DILexicalBlock(scope: !105, file: !1, line: 48, column: 48)
!109 = !DILocation(line: 49, column: 29, scope: !108)
!110 = !DILocation(line: 49, column: 24, scope: !108)
!111 = !DILocation(line: 49, column: 9, scope: !108)
!112 = !DILocation(line: 50, column: 5, scope: !108)
!113 = !DILocation(line: 48, column: 44, scope: !105)
!114 = !DILocation(line: 48, column: 5, scope: !105)
!115 = distinct !{!115, !106, !116, !85}
!116 = !DILocation(line: 50, column: 5, scope: !101)
!117 = !DILocation(line: 51, column: 11, scope: !92)
!118 = !DILocation(line: 52, column: 1, scope: !92)
!119 = distinct !DISubprogram(name: "kyber_wrapper_t", scope: !1, file: !1, line: 55, type: !120, scopeLine: 55, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!120 = !DISubroutineType(types: !121)
!121 = !{null}
!122 = !DILocalVariable(name: "msg", scope: !119, file: !1, line: 56, type: !123)
!123 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 256, elements: !124)
!124 = !{!125}
!125 = !DISubrange(count: 32)
!126 = !DILocation(line: 56, column: 13, scope: !119)
!127 = !DILocalVariable(name: "a", scope: !119, file: !1, line: 57, type: !24)
!128 = !DILocation(line: 57, column: 10, scope: !119)
!129 = !DILocalVariable(name: "i", scope: !130, file: !1, line: 59, type: !40)
!130 = distinct !DILexicalBlock(scope: !119, file: !1, line: 59, column: 5)
!131 = !DILocation(line: 0, scope: !130)
!132 = !DILocation(line: 59, column: 10, scope: !130)
!133 = !DILocation(line: 59, column: 32, scope: !134)
!134 = distinct !DILexicalBlock(scope: !130, file: !1, line: 59, column: 5)
!135 = !DILocation(line: 59, column: 5, scope: !130)
!136 = !DILocation(line: 60, column: 32, scope: !137)
!137 = distinct !DILexicalBlock(scope: !134, file: !1, line: 59, column: 48)
!138 = !DILocation(line: 60, column: 23, scope: !137)
!139 = !DILocation(line: 60, column: 11, scope: !137)
!140 = !DILocation(line: 60, column: 9, scope: !137)
!141 = !DILocation(line: 60, column: 21, scope: !137)
!142 = !DILocation(line: 61, column: 5, scope: !137)
!143 = !DILocation(line: 59, column: 44, scope: !134)
!144 = !DILocation(line: 59, column: 5, scope: !134)
!145 = distinct !{!145, !135, !146, !85}
!146 = !DILocation(line: 61, column: 5, scope: !130)
!147 = !DILocation(line: 63, column: 24, scope: !119)
!148 = !DILocation(line: 63, column: 5, scope: !119)
!149 = !DILocation(line: 64, column: 1, scope: !119)
