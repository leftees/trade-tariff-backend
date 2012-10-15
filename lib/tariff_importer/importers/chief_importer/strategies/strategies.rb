class ChiefImporter
  module Strategies
    class TAME < BaseStrategy
      map fe_tsmp: [0, :chief_date],
          msrgp_code: 2,
          msr_type: 3,
          tty_code: [4, :chief_string],
          tar_msr_no: [5, :chief_code],
          le_tsmp: [6, :chief_date],
          adval_rate: 8,
          alch_sgth: 9,
          audit_tsmp: [10, :chief_date],
          cap_ai_stmt: 11,
          cap_max_pct: 12,
          cmdty_msr_xhdg: 13,
          comp_mthd: 14,
          cpc_wvr_phb: 15,
          ec_msr_set: 16,
          mip_band_exch: 17,
          mip_rate_exch: 18,
          mip_uoq_code: 19,
          nba_id: 20,
          null_tri_rqd: 21,
          qta_code_uk: 22,
          qta_elig_use: 23,
          qta_exch_rate: 24,
          qta_no: 25,
          qta_uoq_code: 26,
          rfa: 27,
          rfs_code_1: 28,
          rfs_code_2: 29,
          rfs_code_3: 30,
          rfs_code_4: 31,
          rfs_code_5: 32,
          tdr_spr_sur: 33,
          exports_use_ind: 34,
          amend_indicator: 1

      process(:update) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Tame.insert map
        end
      }

      process(:insert) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Tame.insert map
        end
      }

      process(:delete) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Tame.insert map
        end
      }
    end

    class TAMF < BaseStrategy
      map fe_tsmp: [0, :chief_date],
          msrgp_code: [2, :chief_string],
          msr_type: [3, :chief_string],
          tty_code: [4, :chief_string],
          tar_msr_no: [5, :chief_code],
          adval1_rate: [7, :chief_decimal],
          adval2_rate: [8, :chief_decimal],
          ai_factor: [9, :chief_string],
          cmdty_dmql: [10, :chief_decimal],
          cmdty_dmql_uoq: [11, :chief_string],
          cngp_code: [12, :chief_string],
          cntry_disp: [13, :chief_string],
          cntry_orig: [14, :chief_string],
          duty_type: [15, :chief_string],
          ec_supplement: [16, :chief_string],
          ec_exch_rate: [17, :chief_string],
          spcl_inst: [18, :chief_string],
          spfc1_cmpd_uoq: [19, :chief_string],
          spfc1_rate: [20, :chief_decimal],
          spfc1_uoq: [21, :chief_string],
          spfc2_rate: [22, :chief_decimal],
          spfc2_uoq: [23, :chief_string],
          spfc3_rate: [24, :chief_decimal],
          spfc3_uoq: [25, :chief_string],
          tamf_dt: [26, :chief_string],
          tamf_sta: [27, :chief_string],
          tamf_ty: [28, :chief_string],
          amend_indicator: 1

      process(:update) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Tamf.insert map
        end
      }
      process(:insert) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Tamf.insert map
        end
      }
      process(:delete) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Tamf.insert map
        end
      }
    end

    class MFCM < BaseStrategy
      map fe_tsmp: [0, :chief_date],
          msrgp_code: 2,
          msr_type: 3,
          tty_code: [4, :chief_string],
          tar_msr_no: [5, :chief_code],
          le_tsmp: [6, :chief_date],
          audit_tsmp: [8, :chief_date],
          cmdty_code: [9, :chief_code],
          cmdty_msr_xhdg: [10, :chief_string],
          null_tri_rqd: [11, :chief_string],
          exports_use_ind: 12,
          amend_indicator: 1

      process(:insert) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
          Chief::Mfcm.insert map
        end
      }

      process(:update) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
            Chief::Mfcm.insert map
        end
      }

      process(:delete) {
        if (prohibition_or_restriction?(map[:msrgp_code]) ||
            vat_or_excise?(map[:msrgp_code])) &&
            !excluded_measure?(map[:msrgp_code], map[:msr_type])
            Chief::Mfcm.insert map
        end
      }
    end
  end
end
