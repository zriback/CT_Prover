; ModuleID = 'kyber-k.ll'
source_filename = "kyber.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-pc-linux-gnu"

%struct.poly = type { [256 x i16] }
%struct.smack_value = type { i8* }

; Function Attrs: noinline nounwind uwtable
define dso_local void @poly_tomsg(i8* %0, %struct.poly* %1) #0 !dbg !14 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !31, metadata !DIExpression()), !dbg !32, !psr.id !33
  call void @llvm.dbg.value(metadata %struct.poly* %1, metadata !34, metadata !DIExpression()), !dbg !32, !psr.id !35
  %3 = getelementptr inbounds %struct.poly, %struct.poly* %1, i32 0, i32 0, !dbg !36, !psr.id !37, !PointTainted !38
  %4 = getelementptr inbounds [256 x i16], [256 x i16]* %3, i64 0, i64 0, !dbg !39, !psr.id !40, !PointTainted !38
  %5 = load i16, i16* %4, align 2, !dbg !39, !psr.id !41, !ValueTainted !42
  %6 = sext i16 %5 to i32, !dbg !39, !psr.id !43, !ValueTainted !42
  call void @llvm.dbg.value(metadata i32 %6, metadata !44, metadata !DIExpression()), !dbg !32, !psr.id !45
  %7 = sdiv i32 %6, 2, !dbg !46, !psr.id !47, !Tainted !48
  call void @llvm.dbg.value(metadata i32 %7, metadata !49, metadata !DIExpression()), !dbg !32, !psr.id !50
  call void @llvm.dbg.value(metadata i32 0, metadata !51, metadata !DIExpression()), !dbg !32, !psr.id !53
  br label %8, !dbg !54, !psr.id !56

8:                                                ; preds = %45, %2
  %.01 = phi i32 [ 0, %2 ], [ %46, %45 ], !dbg !57, !psr.id !58
  call void @llvm.dbg.value(metadata i32 %.01, metadata !51, metadata !DIExpression()), !dbg !32, !psr.id !59
  %9 = icmp ult i32 %.01, 32, !dbg !60, !psr.id !62
  br i1 %9, label %10, label %47, !dbg !63, !psr.id !64

10:                                               ; preds = %8
  %11 = zext i32 %.01 to i64, !dbg !65, !psr.id !67
  %12 = getelementptr inbounds i8, i8* %0, i64 %11, !dbg !65, !psr.id !68, !PointTainted !38
  store i8 0, i8* %12, align 1, !dbg !69, !psr.id !70
  call void @llvm.dbg.value(metadata i32 0, metadata !71, metadata !DIExpression()), !dbg !32, !psr.id !72
  br label %13, !dbg !73, !psr.id !75

13:                                               ; preds = %42, %10
  %.0 = phi i32 [ 0, %10 ], [ %43, %42 ], !dbg !76, !psr.id !77
  call void @llvm.dbg.value(metadata i32 %.0, metadata !71, metadata !DIExpression()), !dbg !32, !psr.id !78
  %14 = icmp ult i32 %.0, 8, !dbg !79, !psr.id !81
  br i1 %14, label %15, label %44, !dbg !82, !psr.id !83

15:                                               ; preds = %13
  %16 = getelementptr inbounds %struct.poly, %struct.poly* %1, i32 0, i32 0, !dbg !84, !psr.id !86, !PointTainted !38
  %17 = mul i32 8, %.01, !dbg !87, !psr.id !88
  %18 = add i32 %17, %.0, !dbg !89, !psr.id !90
  %19 = zext i32 %18 to i64, !dbg !91, !psr.id !92
  %20 = getelementptr inbounds [256 x i16], [256 x i16]* %16, i64 0, i64 %19, !dbg !91, !psr.id !93, !PointTainted !38
  %21 = load i16, i16* %20, align 2, !dbg !91, !psr.id !94, !ValueTainted !42
  call void @llvm.dbg.value(metadata i16 %21, metadata !95, metadata !DIExpression()), !dbg !32, !psr.id !99
  %22 = sext i16 %21 to i32, !dbg !100, !psr.id !101, !ValueTainted !42
  %23 = ashr i32 %22, 15, !dbg !102, !psr.id !103, !ValueTainted !42
  %24 = and i32 %23, 3329, !dbg !104, !psr.id !105, !ValueTainted !42
  %25 = zext i16 %21 to i32, !dbg !106, !psr.id !107, !ValueTainted !42
  %26 = add nsw i32 %25, %24, !dbg !106, !psr.id !108, !ValueTainted !42
  %27 = trunc i32 %26 to i16, !dbg !106, !psr.id !109, !ValueTainted !42
  call void @llvm.dbg.value(metadata i16 %27, metadata !95, metadata !DIExpression()), !dbg !32, !psr.id !110
  %28 = zext i16 %27 to i32, !dbg !111, !psr.id !112, !ValueTainted !42
  %29 = shl i32 %28, 1, !dbg !113, !psr.id !114, !ValueTainted !42
  %30 = add nsw i32 %29, 1664, !dbg !115, !psr.id !116, !ValueTainted !42
  %31 = sdiv i32 %30, 3329, !dbg !117, !psr.id !118, !Tainted !48, !ValueTainted !42
  %32 = and i32 %31, 1, !dbg !119, !psr.id !120, !ValueTainted !42
  %33 = trunc i32 %32 to i16, !dbg !121, !psr.id !122, !ValueTainted !42
  call void @llvm.dbg.value(metadata i16 %33, metadata !95, metadata !DIExpression()), !dbg !32, !psr.id !123
  %34 = zext i16 %33 to i32, !dbg !124, !psr.id !125, !ValueTainted !42
  %35 = shl i32 %34, %.0, !dbg !126, !psr.id !127, !ValueTainted !42
  %36 = zext i32 %.01 to i64, !dbg !128, !psr.id !129
  %37 = getelementptr inbounds i8, i8* %0, i64 %36, !dbg !128, !psr.id !130, !PointTainted !38
  %38 = load i8, i8* %37, align 1, !dbg !131, !psr.id !132, !ValueTainted !42
  %39 = zext i8 %38 to i32, !dbg !131, !psr.id !133, !ValueTainted !42
  %40 = or i32 %39, %35, !dbg !131, !psr.id !134, !ValueTainted !42
  %41 = trunc i32 %40 to i8, !dbg !131, !psr.id !135, !ValueTainted !42
  store i8 %41, i8* %37, align 1, !dbg !131, !psr.id !136
  br label %42, !dbg !137, !psr.id !138

42:                                               ; preds = %15
  %43 = add i32 %.0, 1, !dbg !139, !psr.id !140
  call void @llvm.dbg.value(metadata i32 %43, metadata !71, metadata !DIExpression()), !dbg !32, !psr.id !141
  br label %13, !dbg !142, !llvm.loop !143, !psr.id !146

44:                                               ; preds = %13
  br label %45, !dbg !147, !psr.id !148

45:                                               ; preds = %44
  %46 = add i32 %.01, 1, !dbg !149, !psr.id !150
  call void @llvm.dbg.value(metadata i32 %46, metadata !51, metadata !DIExpression()), !dbg !32, !psr.id !151
  br label %8, !dbg !152, !llvm.loop !153, !psr.id !155

47:                                               ; preds = %8
  ret void, !dbg !156, !psr.id !157
}

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.declare(metadata, metadata, metadata) #1

; Function Attrs: noinline nounwind uwtable
define dso_local void @poly_tomsg_wrapper(i8* %0, %struct.poly* %1) #0 !dbg !158 {
  call void @llvm.dbg.value(metadata i8* %0, metadata !159, metadata !DIExpression()), !dbg !160, !psr.id !161
  call void @llvm.dbg.value(metadata %struct.poly* %1, metadata !162, metadata !DIExpression()), !dbg !160, !psr.id !163
  %3 = call %struct.smack_value* (i8*, ...) bitcast (%struct.smack_value* (...)* @__SMACK_value to %struct.smack_value* (i8*, ...)*)(i8* %0), !dbg !164, !psr.id !165
  call void @public_in(%struct.smack_value* %3), !dbg !166, !psr.id !167
  %4 = call %struct.smack_value* (%struct.poly*, ...) bitcast (%struct.smack_value* (...)* @__SMACK_value to %struct.smack_value* (%struct.poly*, ...)*)(%struct.poly* %1), !dbg !168, !psr.id !169
  call void @public_in(%struct.smack_value* %4), !dbg !170, !psr.id !171
  call void @llvm.dbg.value(metadata i32 0, metadata !172, metadata !DIExpression()), !dbg !174, !psr.id !175
  br label %5, !dbg !176, !psr.id !177

5:                                                ; preds = %13, %2
  %.0 = phi i32 [ 0, %2 ], [ %14, %13 ], !dbg !174, !psr.id !178
  call void @llvm.dbg.value(metadata i32 %.0, metadata !172, metadata !DIExpression()), !dbg !174, !psr.id !179
  %6 = icmp ult i32 %.0, 256, !dbg !180, !psr.id !182
  br i1 %6, label %7, label %15, !dbg !183, !psr.id !184

7:                                                ; preds = %5
  %8 = getelementptr inbounds %struct.poly, %struct.poly* %1, i32 0, i32 0, !dbg !185, !psr.id !187, !PointTainted !38
  %9 = zext i32 %.0 to i64, !dbg !188, !psr.id !189
  %10 = getelementptr inbounds [256 x i16], [256 x i16]* %8, i64 0, i64 %9, !dbg !188, !psr.id !190, !PointTainted !38
  %11 = load i16, i16* %10, align 2, !dbg !188, !psr.id !191, !ValueTainted !42
  %12 = sext i16 %11 to i32, !dbg !192, !psr.id !193, !ValueTainted !42
  call void @vfct_taintseed(i32 %12), !dbg !194, !psr.id !195
  br label %13, !dbg !196, !psr.id !197

13:                                               ; preds = %7
  %14 = add i32 %.0, 1, !dbg !198, !psr.id !199
  call void @llvm.dbg.value(metadata i32 %14, metadata !172, metadata !DIExpression()), !dbg !174, !psr.id !200
  br label %5, !dbg !201, !llvm.loop !202, !psr.id !204

15:                                               ; preds = %5
  call void @poly_tomsg(i8* %0, %struct.poly* %1), !dbg !205, !psr.id !206
  ret void, !dbg !207, !psr.id !208
}

declare dso_local void @public_in(%struct.smack_value*) #2

declare dso_local %struct.smack_value* @__SMACK_value(...) #2

declare dso_local void @vfct_taintseed(i32) #2

; Function Attrs: noinline nounwind uwtable
define dso_local void @kyber_wrapper_t() #0 !dbg !209 {
  %1 = alloca [32 x i8], align 16, !psr.id !212
  %2 = alloca %struct.poly, align 2, !psr.id !213
  call void @llvm.dbg.declare(metadata [32 x i8]* %1, metadata !214, metadata !DIExpression()), !dbg !218, !psr.id !219
  call void @llvm.dbg.declare(metadata %struct.poly* %2, metadata !220, metadata !DIExpression()), !dbg !221, !psr.id !222
  call void @llvm.dbg.value(metadata i32 0, metadata !223, metadata !DIExpression()), !dbg !225, !psr.id !226
  br label %3, !dbg !227, !psr.id !228

3:                                                ; preds = %11, %0
  %.0 = phi i32 [ 0, %0 ], [ %12, %11 ], !dbg !225, !psr.id !229
  call void @llvm.dbg.value(metadata i32 %.0, metadata !223, metadata !DIExpression()), !dbg !225, !psr.id !230
  %4 = icmp ult i32 %.0, 256, !dbg !231, !psr.id !233
  br i1 %4, label %5, label %13, !dbg !234, !psr.id !235

5:                                                ; preds = %3
  %6 = call i32 @getint32(), !dbg !236, !psr.id !238
  %7 = trunc i32 %6 to i16, !dbg !239, !psr.id !240
  %8 = getelementptr inbounds %struct.poly, %struct.poly* %2, i32 0, i32 0, !dbg !241, !psr.id !242
  %9 = zext i32 %.0 to i64, !dbg !243, !psr.id !244
  %10 = getelementptr inbounds [256 x i16], [256 x i16]* %8, i64 0, i64 %9, !dbg !243, !psr.id !245
  store i16 %7, i16* %10, align 2, !dbg !246, !psr.id !247
  br label %11, !dbg !248, !psr.id !249

11:                                               ; preds = %5
  %12 = add i32 %.0, 1, !dbg !250, !psr.id !251
  call void @llvm.dbg.value(metadata i32 %12, metadata !223, metadata !DIExpression()), !dbg !225, !psr.id !252
  br label %3, !dbg !253, !llvm.loop !254, !psr.id !256

13:                                               ; preds = %3
  %14 = getelementptr inbounds [32 x i8], [32 x i8]* %1, i64 0, i64 0, !dbg !257, !psr.id !258
  call void @poly_tomsg_wrapper(i8* %14, %struct.poly* %2), !dbg !259, !psr.id !260
  ret void, !dbg !261, !psr.id !262
}

declare dso_local i32 @getint32() #2

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

define void @__psrCRuntimeGlobalDtorsModel() {
entry:
  ret void
}

define void @__psrCRuntimeGlobalCtorsModel(i32 %0, i8** %1) {
entry:
  call void @kyber_wrapper_t()
  ret void
}

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
!33 = !{!"0"}
!34 = !DILocalVariable(name: "a", arg: 2, scope: !14, file: !1, line: 25, type: !22)
!35 = !{!"1"}
!36 = !DILocation(line: 30, column: 19, scope: !14)
!37 = !{!"2"}
!38 = !{!"PointTainted"}
!39 = !DILocation(line: 30, column: 16, scope: !14)
!40 = !{!"3"}
!41 = !{!"4"}
!42 = !{!"ValueTainted"}
!43 = !{!"5"}
!44 = !DILocalVariable(name: "this", scope: !14, file: !1, line: 30, type: !9)
!45 = !{!"6"}
!46 = !DILocation(line: 31, column: 20, scope: !14)
!47 = !{!"7"}
!48 = !{!"Tainted"}
!49 = !DILocalVariable(name: "huh", scope: !14, file: !1, line: 31, type: !9)
!50 = !{!"8"}
!51 = !DILocalVariable(name: "i", scope: !14, file: !1, line: 27, type: !52)
!52 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!53 = !{!"9"}
!54 = !DILocation(line: 33, column: 9, scope: !55)
!55 = distinct !DILexicalBlock(scope: !14, file: !1, line: 33, column: 5)
!56 = !{!"10"}
!57 = !DILocation(line: 0, scope: !55)
!58 = !{!"11"}
!59 = !{!"12"}
!60 = !DILocation(line: 33, column: 14, scope: !61)
!61 = distinct !DILexicalBlock(scope: !55, file: !1, line: 33, column: 5)
!62 = !{!"13"}
!63 = !DILocation(line: 33, column: 5, scope: !55)
!64 = !{!"14"}
!65 = !DILocation(line: 34, column: 9, scope: !66)
!66 = distinct !DILexicalBlock(scope: !61, file: !1, line: 33, column: 30)
!67 = !{!"15"}
!68 = !{!"16"}
!69 = !DILocation(line: 34, column: 16, scope: !66)
!70 = !{!"17"}
!71 = !DILocalVariable(name: "j", scope: !14, file: !1, line: 27, type: !52)
!72 = !{!"18"}
!73 = !DILocation(line: 35, column: 13, scope: !74)
!74 = distinct !DILexicalBlock(scope: !66, file: !1, line: 35, column: 9)
!75 = !{!"19"}
!76 = !DILocation(line: 0, scope: !74)
!77 = !{!"20"}
!78 = !{!"21"}
!79 = !DILocation(line: 35, column: 18, scope: !80)
!80 = distinct !DILexicalBlock(scope: !74, file: !1, line: 35, column: 9)
!81 = !{!"22"}
!82 = !DILocation(line: 35, column: 9, scope: !74)
!83 = !{!"23"}
!84 = !DILocation(line: 36, column: 21, scope: !85)
!85 = distinct !DILexicalBlock(scope: !80, file: !1, line: 35, column: 26)
!86 = !{!"24"}
!87 = !DILocation(line: 36, column: 29, scope: !85)
!88 = !{!"25"}
!89 = !DILocation(line: 36, column: 31, scope: !85)
!90 = !{!"26"}
!91 = !DILocation(line: 36, column: 18, scope: !85)
!92 = !{!"27"}
!93 = !{!"28"}
!94 = !{!"29"}
!95 = !DILocalVariable(name: "t", scope: !14, file: !1, line: 28, type: !96)
!96 = !DIDerivedType(tag: DW_TAG_typedef, name: "uint16_t", file: !19, line: 25, baseType: !97)
!97 = !DIDerivedType(tag: DW_TAG_typedef, name: "__uint16_t", file: !7, line: 40, baseType: !98)
!98 = !DIBasicType(name: "unsigned short", size: 16, encoding: DW_ATE_unsigned)
!99 = !{!"30"}
!100 = !DILocation(line: 37, column: 19, scope: !85)
!101 = !{!"31"}
!102 = !DILocation(line: 37, column: 30, scope: !85)
!103 = !{!"32"}
!104 = !DILocation(line: 37, column: 37, scope: !85)
!105 = !{!"33"}
!106 = !DILocation(line: 37, column: 15, scope: !85)
!107 = !{!"34"}
!108 = !{!"35"}
!109 = !{!"36"}
!110 = !{!"37"}
!111 = !DILocation(line: 38, column: 21, scope: !85)
!112 = !{!"38"}
!113 = !DILocation(line: 38, column: 23, scope: !85)
!114 = !{!"39"}
!115 = !DILocation(line: 38, column: 29, scope: !85)
!116 = !{!"40"}
!117 = !DILocation(line: 38, column: 41, scope: !85)
!118 = !{!"41"}
!119 = !DILocation(line: 38, column: 51, scope: !85)
!120 = !{!"42"}
!121 = !DILocation(line: 38, column: 18, scope: !85)
!122 = !{!"43"}
!123 = !{!"44"}
!124 = !DILocation(line: 39, column: 23, scope: !85)
!125 = !{!"45"}
!126 = !DILocation(line: 39, column: 25, scope: !85)
!127 = !{!"46"}
!128 = !DILocation(line: 39, column: 13, scope: !85)
!129 = !{!"47"}
!130 = !{!"48"}
!131 = !DILocation(line: 39, column: 20, scope: !85)
!132 = !{!"49"}
!133 = !{!"50"}
!134 = !{!"51"}
!135 = !{!"52"}
!136 = !{!"53"}
!137 = !DILocation(line: 40, column: 9, scope: !85)
!138 = !{!"54"}
!139 = !DILocation(line: 35, column: 22, scope: !80)
!140 = !{!"55"}
!141 = !{!"56"}
!142 = !DILocation(line: 35, column: 9, scope: !80)
!143 = distinct !{!143, !82, !144, !145}
!144 = !DILocation(line: 40, column: 9, scope: !74)
!145 = !{!"llvm.loop.mustprogress"}
!146 = !{!"57"}
!147 = !DILocation(line: 41, column: 5, scope: !66)
!148 = !{!"58"}
!149 = !DILocation(line: 33, column: 26, scope: !61)
!150 = !{!"59"}
!151 = !{!"60"}
!152 = !DILocation(line: 33, column: 5, scope: !61)
!153 = distinct !{!153, !63, !154, !145}
!154 = !DILocation(line: 41, column: 5, scope: !55)
!155 = !{!"61"}
!156 = !DILocation(line: 42, column: 1, scope: !14)
!157 = !{!"62"}
!158 = distinct !DISubprogram(name: "poly_tomsg_wrapper", scope: !1, file: !1, line: 44, type: !15, scopeLine: 45, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!159 = !DILocalVariable(name: "msg", arg: 1, scope: !158, file: !1, line: 44, type: !17)
!160 = !DILocation(line: 0, scope: !158)
!161 = !{!"63"}
!162 = !DILocalVariable(name: "a", arg: 2, scope: !158, file: !1, line: 44, type: !22)
!163 = !{!"64"}
!164 = !DILocation(line: 46, column: 15, scope: !158)
!165 = !{!"65"}
!166 = !DILocation(line: 46, column: 5, scope: !158)
!167 = !{!"66"}
!168 = !DILocation(line: 47, column: 15, scope: !158)
!169 = !{!"67"}
!170 = !DILocation(line: 47, column: 5, scope: !158)
!171 = !{!"68"}
!172 = !DILocalVariable(name: "i", scope: !173, file: !1, line: 48, type: !52)
!173 = distinct !DILexicalBlock(scope: !158, file: !1, line: 48, column: 5)
!174 = !DILocation(line: 0, scope: !173)
!175 = !{!"69"}
!176 = !DILocation(line: 48, column: 10, scope: !173)
!177 = !{!"70"}
!178 = !{!"71"}
!179 = !{!"72"}
!180 = !DILocation(line: 48, column: 32, scope: !181)
!181 = distinct !DILexicalBlock(scope: !173, file: !1, line: 48, column: 5)
!182 = !{!"73"}
!183 = !DILocation(line: 48, column: 5, scope: !173)
!184 = !{!"74"}
!185 = !DILocation(line: 49, column: 32, scope: !186)
!186 = distinct !DILexicalBlock(scope: !181, file: !1, line: 48, column: 48)
!187 = !{!"75"}
!188 = !DILocation(line: 49, column: 29, scope: !186)
!189 = !{!"76"}
!190 = !{!"77"}
!191 = !{!"78"}
!192 = !DILocation(line: 49, column: 24, scope: !186)
!193 = !{!"79"}
!194 = !DILocation(line: 49, column: 9, scope: !186)
!195 = !{!"80"}
!196 = !DILocation(line: 50, column: 5, scope: !186)
!197 = !{!"81"}
!198 = !DILocation(line: 48, column: 44, scope: !181)
!199 = !{!"82"}
!200 = !{!"83"}
!201 = !DILocation(line: 48, column: 5, scope: !181)
!202 = distinct !{!202, !183, !203, !145}
!203 = !DILocation(line: 50, column: 5, scope: !173)
!204 = !{!"84"}
!205 = !DILocation(line: 51, column: 11, scope: !158)
!206 = !{!"85"}
!207 = !DILocation(line: 52, column: 1, scope: !158)
!208 = !{!"86"}
!209 = distinct !DISubprogram(name: "kyber_wrapper_t", scope: !1, file: !1, line: 55, type: !210, scopeLine: 55, flags: DIFlagPrototyped, spFlags: DISPFlagDefinition, unit: !0, retainedNodes: !2)
!210 = !DISubroutineType(types: !211)
!211 = !{null}
!212 = !{!"87"}
!213 = !{!"88"}
!214 = !DILocalVariable(name: "msg", scope: !209, file: !1, line: 56, type: !215)
!215 = !DICompositeType(tag: DW_TAG_array_type, baseType: !18, size: 256, elements: !216)
!216 = !{!217}
!217 = !DISubrange(count: 32)
!218 = !DILocation(line: 56, column: 13, scope: !209)
!219 = !{!"89"}
!220 = !DILocalVariable(name: "a", scope: !209, file: !1, line: 57, type: !24)
!221 = !DILocation(line: 57, column: 10, scope: !209)
!222 = !{!"90"}
!223 = !DILocalVariable(name: "i", scope: !224, file: !1, line: 59, type: !52)
!224 = distinct !DILexicalBlock(scope: !209, file: !1, line: 59, column: 5)
!225 = !DILocation(line: 0, scope: !224)
!226 = !{!"91"}
!227 = !DILocation(line: 59, column: 10, scope: !224)
!228 = !{!"92"}
!229 = !{!"93"}
!230 = !{!"94"}
!231 = !DILocation(line: 59, column: 32, scope: !232)
!232 = distinct !DILexicalBlock(scope: !224, file: !1, line: 59, column: 5)
!233 = !{!"95"}
!234 = !DILocation(line: 59, column: 5, scope: !224)
!235 = !{!"96"}
!236 = !DILocation(line: 60, column: 32, scope: !237)
!237 = distinct !DILexicalBlock(scope: !232, file: !1, line: 59, column: 48)
!238 = !{!"97"}
!239 = !DILocation(line: 60, column: 23, scope: !237)
!240 = !{!"98"}
!241 = !DILocation(line: 60, column: 11, scope: !237)
!242 = !{!"99"}
!243 = !DILocation(line: 60, column: 9, scope: !237)
!244 = !{!"100"}
!245 = !{!"101"}
!246 = !DILocation(line: 60, column: 21, scope: !237)
!247 = !{!"102"}
!248 = !DILocation(line: 61, column: 5, scope: !237)
!249 = !{!"103"}
!250 = !DILocation(line: 59, column: 44, scope: !232)
!251 = !{!"104"}
!252 = !{!"105"}
!253 = !DILocation(line: 59, column: 5, scope: !232)
!254 = distinct !{!254, !234, !255, !145}
!255 = !DILocation(line: 61, column: 5, scope: !224)
!256 = !{!"106"}
!257 = !DILocation(line: 63, column: 24, scope: !209)
!258 = !{!"107"}
!259 = !DILocation(line: 63, column: 5, scope: !209)
!260 = !{!"108"}
!261 = !DILocation(line: 64, column: 1, scope: !209)
!262 = !{!"109"}
