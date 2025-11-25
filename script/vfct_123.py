#!/usr/bin/python3
"""Run only the one_and_two_and_three pipeline.

This script mirrors the 1+2+3 workflow in vfct_all.py but skips all
other pipelines (single_one, one_and_two, chaifen variants, etc.).
Run it from a benchmark directory (e.g., bech/OpenSSL/... ).
"""

import os

import vfct_all as vfct


def run_one_two_three_only():
    dirname = "one_and_two_and_three"
    vfct.mkdir(dirname)

    # Ensure the LLVM IR for each entry is available inside the working
    # directory, matching the behavior of vfct_find_bug's helper.
    for item in vfct.entry:
        vfct.runcommand(f"cp {item}.ll {dirname}")

    total = []
    phase1 = []
    phase2 = []
    phase2_loopfix = []
    phase3 = []

    vfct.loc.clear()
    vfct.allsens.clear()
    vfct.taint_res.clear()
    vfct.Is_taint_pass.clear()
    vfct.Is_high_taint_1_2_pass.clear()
    vfct.detailtime_1_2_3.clear()
    vfct.totaltime_1_2_3.clear()

    for item in vfct.entry:
        file = f"{item}.ll"
        tkfile = f"{item}-k.ll"
        taintentry = f"{item}_wrapper_t"
        taintconfig = f"{item}.json"
        outfile = f"{item}-taintres.txt"

        taintfile = f"{item}-t.ll"
        boogiefile = f"{item}.bpl"
        boolboogiefile = f"{item}-bool.bpl"
        boolboogiefilenoloop = f"{item}-bool_Noloop.bpl"
        tmpboogiefile = f"{item}-tmp.bpl"
        shadowboogiefile = f"{item}-shadow.bpl"
        analyres = f"{item}-1-2.txt"
        analyres2 = f"{item}-1-22.txt"
        boogieentry = f"{item}_wrapper"
        trasnsres = f"{item}-trans.txt"
        finalres = f"{item}-1-2-3.txt"
        record = f"{item}-record.txt"

        vfct.runcommand(f"cp {taintconfig} {dirname}")

        restime1 = vfct.addkey(file, tkfile, dirname)
        restime2 = vfct.phasar(tkfile, taintentry, taintconfig, outfile, dirname)

        restime3 = vfct.generatebpl(taintfile, boogieentry, boogiefile, dirname)
        restime4 = vfct.productbpl(
            boogiefile,
            boolboogiefile,
            vfct.AcceptTaint,
            vfct.BoolProduct,
            vfct.SplitAssert,
            dirname,
            record,
        )
        restime5 = vfct.verify_without_timelimit(boolboogiefile, analyres, dirname, 5)

        t6 = vfct.markbpl(analyres, boolboogiefile, dirname)
        t7 = vfct.verify_without_timelimit(boolboogiefilenoloop, analyres2, dirname, 0)
        t8 = vfct.productbpl(
            boogiefile,
            tmpboogiefile,
            vfct.AcceptTaint,
            vfct.ShadowProduct,
            vfct.NoSplitAssert,
            dirname,
        )
        t9, t10 = vfct.newtransfer(
            analyres, analyres2, tmpboogiefile, shadowboogiefile, trasnsres, dirname
        )
        t11 = vfct.verifybpl(shadowboogiefile, finalres, dirname)

        locinfo = vfct.getloc_and_taintres_info(os.path.join(dirname, record))
        vfct.loc.append(locinfo[3])
        vfct.taint_res.append(locinfo[1])
        vfct.Is_taint_pass.append(vfct.taint_pass(locinfo[1]))
        vfct.Is_high_taint_1_2_pass.append(vfct.high_taint_pass(os.path.join(dirname, analyres)))
        vfct.allsens.append(locinfo[0])

        phase1.append(restime1 + restime2)
        phase2.append(restime3 + restime4 + restime5)
        phase2_loopfix.append(t6 + t7)
        phase3.append(t8 + t9 + t10 + t11)
        total.append(
            restime1
            + restime2
            + restime3
            + restime4
            + restime5
            + t6
            + t7
            + t8
            + t9
            + t10
            + t11
        )

    vfct.detailtime_1_2_3 = [
        ("1", phase1),
        ("2", phase2),
        ("2-2", phase2_loopfix),
        ("3", phase3),
    ]
    vfct.totaltime_1_2_3 = [("1+2+3", total)]


def runall():
    vfct.preprocess()
    vfct.readconfig()
    vfct.iterdir(os.getcwd())
    vfct.buildbech()

    run_one_two_three_only()

    vfct.totaltime = list(vfct.totaltime_1_2_3)
    vfct.detailtime = list(vfct.detailtime_1_2_3)
    vfct.verifytime = []

    vfct.collectinfo()
    vfct.collcet_time(vfct.totaltime, "totaltime.csv")
    vfct.collcet_time(vfct.detailtime, "detailtime.csv")
    vfct.collcet_time(vfct.verifytime, "verifytime.csv")


if __name__ == "__main__":
    runall()
