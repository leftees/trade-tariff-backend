require 'rails_helper'

describe Measure do
  describe '#id' do
    let(:measure) { build :measure }

    it 'is an alias to #measure_sid' do
      expect(measure.id).to eq measure.measure_sid
    end
  end

  describe '#generating_regulation' do
    let(:measure_of_base_regulation) { create :measure }
    let(:measure_of_modification_regulation) { create :measure, :with_modification_regulation }

    it 'returns relevant regulation that is generating the measure' do
      expect(measure_of_base_regulation.generating_regulation).to eq measure_of_base_regulation.base_regulation
      expect(measure_of_modification_regulation.generating_regulation).to eq measure_of_modification_regulation.modification_regulation
    end
  end

  # According to Taric guide
  describe '#validity_end_date' do
    let(:base_regulation) { create :base_regulation, effective_end_date: Date.yesterday }
    let(:measure) { create :measure, measure_generating_regulation_role: 1,
                                     base_regulation: base_regulation,
                                     validity_end_date: Date.today }

    context 'measure end date greater than generating regulation end date' do
      it 'returns validity end date of' do
        expect(measure.validity_end_date.to_date).to eq base_regulation.effective_end_date.to_date
      end
    end

    context 'measure end date lesser than generating regulation end date' do
      let(:base_regulation) { create :base_regulation, effective_end_date: Date.today }
      let(:measure) { create :measure, measure_generating_regulation_role: 1,
                                       base_regulation: base_regulation,
                                       validity_end_date: Date.yesterday }

      it 'returns validity end date of the measure' do
        expect(measure.validity_end_date.to_date).to eq measure.validity_end_date.to_date
      end
    end

    context 'generating regulation effective end date blank, measure end date blank' do
      let(:base_regulation) { create :base_regulation, effective_end_date: nil }
      let(:measure) { create :measure, measure_generating_regulation_role: 1,
                                       base_regulation: base_regulation,
                                       validity_end_date: nil }

      it 'returns validity end date of the measure' do
        expect(measure.validity_end_date).to be_blank
      end
    end

    context 'generating regulation effective end date blank, measure end date present' do
      let(:base_regulation) { create :base_regulation, effective_end_date: nil }
      let(:measure) { create :measure, measure_generating_regulation_role: 1,
                                       base_regulation: base_regulation,
                                       validity_end_date: Date.today }

      it 'returns validity end date of the measure' do
        expect(measure.validity_end_date).to be_blank
      end
    end

    context 'generating regulation effective end date present, measure end date blank' do
      let(:base_regulation) { create :base_regulation, effective_end_date: Date.today}
      let(:measure) { create :measure, measure_generating_regulation_role: 1,
                                       base_regulation: base_regulation,
                                       validity_end_date: nil }

      it 'returns validity end date of the measure' do
        expect(measure.validity_end_date.to_date).to eq Date.today
      end
    end

    context 'measure is national' do
      let(:base_regulation) { create :base_regulation, effective_end_date: Date.yesterday }
      let(:measure) { create :measure, measure_generating_regulation_role: 1,
                                       base_regulation: base_regulation,
                                       validity_end_date: Date.today,
                                       national:true }

      it 'returns validity end date of the measure' do
        expect(measure.validity_end_date.to_date).to eq Date.today
      end
    end
  end

  describe 'associations' do
    describe 'measure type' do
      let!(:measure)         { create :measure }
      let!(:measure_type1)   { create :measure_type, measure_type_id: measure.measure_type_id,
                                                     validity_start_date: 5.years.ago,
                                                     validity_end_date: 3.years.ago,
                                                     operation_date: Date.yesterday }
      let!(:measure_type2)   { create :measure_type, measure_type_id: measure.measure_type_id,
                                                     validity_start_date: 2.years.ago,
                                                     validity_end_date: nil,
                                                     operation: :update }

      context 'direct loading' do
        it 'loads correct description respecting given actual time' do
          TimeMachine.now do
            expect(measure.measure_type.pk).to eq measure_type1.pk
          end
        end

        it 'loads correct description respecting given time' do
          TimeMachine.at(1.year.ago) do
            expect(measure.measure_type.pk).to eq measure_type1.pk
          end
        end
      end

      context 'eager loading' do
        it 'loads correct description respecting given actual time' do
          TimeMachine.now do
            expect(
              Measure.where(measure_sid: measure.measure_sid)
                          .eager(:measure_type)
                          .all
                          .first
                          .measure_type.pk
            ).to eq measure_type1.pk
          end
        end

        it 'loads correct description respecting given time' do
          TimeMachine.at(1.year.ago) do
            expect(
              Measure.where(measure_sid: measure.measure_sid)
                          .eager(:measure_type)
                          .all
                          .first
                          .measure_type.pk
            ).to eq measure_type1.pk
          end
        end
      end
    end

    describe 'measure conditions' do
      let!(:measure)                { create :measure }
      let!(:measure_condition1)     { create :measure_condition, measure_sid: measure.measure_sid }
      let!(:measure_condition2)     { create :measure_condition }

      context 'direct loading' do
        it 'loads associated measure conditions' do
          expect(measure.measure_conditions).to include measure_condition1
        end

        it 'does not load associated measure condition' do
          expect(measure.measure_conditions).to_not include measure_condition2
        end
      end

      context 'eager loading' do
        it 'loads associated measure conditions' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:measure_conditions)
                 .all
                 .first
                 .measure_conditions
          ).to include measure_condition1
        end

        it 'does not load associated measure condition' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:measure_conditions)
                 .all
                 .first
                 .measure_conditions
          ).to_not include measure_condition2
        end
      end

      describe 'ordering' do
        let!(:measure)                { create :measure }
        let!(:measure_condition1)     { create :measure_condition, measure_sid: measure.measure_sid, condition_code: 'L', component_sequence_number: 10 }
        let!(:measure_condition2)     { create :measure_condition, measure_sid: measure.measure_sid, condition_code: 'A', component_sequence_number: 1 }

        it 'loads conditions ordered by component sequence number ascending' do
          expect(measure.measure_conditions.first).to eq measure_condition2
          expect(measure.measure_conditions.last).to eq measure_condition1
        end
      end
    end

    describe 'geographical area' do
      let!(:geographical_area1)     { create :geographical_area, geographical_area_id: 'ab' }
      let!(:geographical_area2)     { create :geographical_area, geographical_area_id: 'de' }
      let!(:measure)                { create :measure, geographical_area_sid: geographical_area1.geographical_area_sid }

      context 'direct loading' do
        it 'loads associated measure conditions' do
          expect(measure.geographical_area.pk).to eq geographical_area1.pk
        end

        it 'does not load associated measure condition' do
          expect(measure.geographical_area.pk).to_not eq geographical_area2.pk
        end
      end

      context 'eager loading' do
        it 'loads associated measure conditions' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:geographical_area)
                 .all
                 .first
                 .geographical_area.pk
          ).to eq geographical_area1.pk
        end

        it 'does not load associated measure condition' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:geographical_area)
                 .all
                 .first
                 .geographical_area.pk
          ).to_not eq geographical_area2.pk
        end
      end
    end

    describe 'footnotes' do
      let!(:measure)          { create :measure }
      let!(:footnote1)        { create :footnote, validity_start_date: 2.years.ago,
                                                  validity_end_date: nil }
      let!(:footnote1_assoc)  { create :footnote_association_measure, measure_sid: measure.measure_sid,
                                                                      footnote_id: footnote1.footnote_id,
                                                                      footnote_type_id: footnote1.footnote_type_id }
      let!(:footnote2)        { create :footnote, validity_start_date: 5.years.ago,
                                                  validity_end_date: 3.years.ago }
      let!(:footnote2_assoc)  { create :footnote_association_measure, measure_sid: measure.measure_sid,
                                                                      footnote_id: footnote2.footnote_id,
                                                                      footnote_type_id: footnote2.footnote_type_id }

      context 'direct loading' do
        it 'loads correct indent respecting given actual time' do
          TimeMachine.now do
            expect(
              measure.footnotes.map(&:pk)
            ).to include footnote1.pk
          end
        end

        it 'loads correct indent respecting given time' do
          TimeMachine.at(1.year.ago) do
            expect(
              measure.footnotes.map(&:pk)
            ).to include footnote1.pk
          end

          TimeMachine.at(4.years.ago) do
            expect(
              measure.reload.footnotes.map(&:pk)
            ).to include footnote2.pk
          end
        end
      end

      context 'eager loading' do
        it 'loads correct indent respecting given actual time' do
          TimeMachine.now do
            expect(
              Measure.where(measure_sid: measure.measure_sid)
                          .eager(:footnotes)
                          .all
                          .first
                          .footnotes.map(&:pk)
            ).to include footnote1.pk
          end
        end

        it 'loads correct indent respecting given time' do
          TimeMachine.at(1.year.ago) do
            expect(
              Measure.where(measure_sid: measure.measure_sid)
                          .eager(:footnotes)
                          .all
                          .first
                          .footnotes.map(&:pk)
            ).to include footnote1.pk
          end

          TimeMachine.at(4.years.ago) do
            expect(
              Measure.where(measure_sid: measure.measure_sid)
                          .eager(:footnotes)
                          .all
                          .first
                          .footnotes.map(&:pk)
            ).to include footnote2.pk
          end
        end
      end
    end

    describe 'measure components' do
      let!(:measure)                { create :measure }
      let!(:measure_component1)     { create :measure_component, measure_sid: measure.measure_sid }
      let!(:measure_component2)     { create :measure_component }

      context 'direct loading' do
        it 'loads associated measure components' do
          expect(measure.measure_components).to include measure_component1
        end

        it 'does not load associated measure component' do
          expect(measure.measure_components).to_not include measure_component2
        end
      end

      context 'eager loading' do
        it 'loads associated measure components' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:measure_components)
                 .all
                 .first
                 .measure_components
          ).to include measure_component1
        end

        it 'does not load associated measure component' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:measure_components)
                 .all
                 .first
                 .measure_components
          ).to_not include measure_component2
        end
      end
    end

    describe 'additional code' do
      let!(:additional_code1)     { create :additional_code, validity_start_date: Date.today.ago(3.years) }
      let!(:additional_code2)     { create :additional_code, validity_start_date: Date.today.ago(5.years) }
      let!(:measure)              { create :measure, additional_code_sid: additional_code1.additional_code_sid }

      context 'direct loading' do
        it 'loads associated measure conditions' do
          expect(measure.additional_code).to eq additional_code1
        end

        it 'does not load associated measure condition' do
          expect(measure.additional_code).to_not eq additional_code2
        end
      end

      context 'eager loading' do
        it 'loads associated measure conditions' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:additional_code)
                 .all
                 .first
                 .additional_code
          ).to eq additional_code1
        end

        it 'does not load associated measure condition' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:additional_code)
                 .all
                 .first
                 .additional_code
          ).to_not eq additional_code2
        end
      end
    end

    describe 'quota order number' do
      let!(:quota_order_number1)     { create :quota_order_number, validity_start_date: Date.today.ago(3.years) }
      let!(:quota_order_number2)     { create :quota_order_number, validity_start_date: Date.today.ago(5.years) }
      let!(:measure)                 { create :measure, ordernumber: quota_order_number1.quota_order_number_id }

      context 'direct loading' do
        it 'loads associated measure conditions' do
          expect(measure.quota_order_number).to eq quota_order_number1
        end

        it 'does not load associated measure condition' do
          expect(measure.quota_order_number).to_not eq quota_order_number2
        end
      end

      context 'eager loading' do
        it 'loads associated measure conditions' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:quota_order_number)
                 .all
                 .first
                 .quota_order_number
          ).to eq quota_order_number1
        end

        it 'does not load associated measure condition' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:quota_order_number)
                 .all
                 .first
                 .quota_order_number
          ).to_not eq quota_order_number2
        end
      end
    end

    describe 'full temporary stop regulation' do
      let!(:fts_regulation1)        { create :fts_regulation, validity_start_date: Date.today.ago(3.years) }
      let!(:fts_regulation2)        { create :fts_regulation, validity_start_date: Date.today.ago(5.years) }
      let!(:fts_regulation_action1) { create :fts_regulation_action, fts_regulation_id: fts_regulation1.full_temporary_stop_regulation_id }
      let!(:fts_regulation_action2) { create :fts_regulation_action, fts_regulation_id: fts_regulation2.full_temporary_stop_regulation_id }
      let!(:measure)                { create :measure, measure_generating_regulation_id: fts_regulation_action1.stopped_regulation_id }

      context 'direct loading' do
        it 'loads associated full temporary stop regulation' do
          expect(measure.full_temporary_stop_regulation.pk).to eq fts_regulation1.pk
        end

        it 'does not load associated full temporary stop regulation' do
          expect(measure.full_temporary_stop_regulation.pk).to_not eq fts_regulation2.pk
        end
      end

      context 'eager loading' do
        it 'loads associated full temporary stop regulation' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:full_temporary_stop_regulations)
                 .all
                 .first
                 .full_temporary_stop_regulation.pk
          ).to eq fts_regulation1.pk
        end

        it 'does not load associated full temporary stop regulation' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:full_temporary_stop_regulations)
                 .all
                 .first
                 .full_temporary_stop_regulation.pk
          ).to_not eq fts_regulation2.pk
        end
      end
    end

    describe 'measure partial temporary stop' do
      let!(:mpt_stop1)        { create :measure_partial_temporary_stop, validity_start_date: Date.today.ago(3.years) }
      let!(:mpt_stop2)        { create :measure_partial_temporary_stop, validity_start_date: Date.today.ago(5.years) }
      let!(:measure)          { create :measure, measure_generating_regulation_id: mpt_stop1.partial_temporary_stop_regulation_id }

      context 'direct loading' do
        it 'loads associated full temporary stop regulation' do
          expect(measure.measure_partial_temporary_stop.pk).to eq mpt_stop1.pk
        end

        it 'does not load associated full temporary stop regulation' do
          expect(measure.measure_partial_temporary_stop.pk).to_not eq mpt_stop2.pk
        end
      end

      context 'eager loading' do
        it 'loads associated full temporary stop regulation' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:measure_partial_temporary_stops)
                 .all
                 .first
                 .measure_partial_temporary_stop.pk
          ).to eq mpt_stop1.pk
        end

        it 'does not load associated full temporary stop regulation' do
          expect(
            Measure.where(measure_sid: measure.measure_sid)
                 .eager(:measure_partial_temporary_stops)
                 .all
                 .first
                 .measure_partial_temporary_stop.pk
          ).to_not eq mpt_stop2.pk
        end
      end
    end
  end

  describe 'validations' do
    # ME2 ME4 ME6 ME24 The <field name> must exist.
    it { is_expected.to validate_presence.of(:measure_type) }
    # ME4
    it { is_expected.to validate_presence.of(:geographical_area) }
    # ME6
    it { is_expected.to validate_presence.of(:goods_nomenclature) }
    # ME24
    it { is_expected.to validate_presence.of(:measure_generating_role_id) }
    it { is_expected.to validate_presence.of(:measure_generating_role_type) }
    # ME1 The combination of measure type + geographical area +
    #     goods nomenclature item id + additional code type + additional code +
    #     order number + reduction indicator + start date must be unique
    it { is_expected.to validate_uniqueness.of([:measure_type_id,
                                        :geographical_area_sid,
                                        :goods_nomenclature_sid,
                                        :additional_code_type_id,
                                        :additional_code_id,
                                        :ordernumber,
                                        :reduction_indicator,
                                        :validity_start_date]) }
    # ME4 ME5
    it { is_expected.to validate_validity_date_span.of(:geographical_area) }
    # ME2 ME3
    it { is_expected.to validate_validity_date_span.of(:measure_type) }
    # ME6 ME8
    it { is_expected.to validate_validity_date_span.of(:goods_nomenclature) }
    # ME25 If the measures end date is specified (implicitly or explicitly)
    # then the start date of the measure must be less than
    # or equal to the end date
    it { is_expected.to validate_validity_dates }

    describe 'ME7' do
      let(:measure1) { create :measure, gono_producline_suffix: "80" }
      let(:measure2) { create :measure, gono_producline_suffix: "20" }

      it 'performs validation' do
        expect(measure1).to be_conformant
        expect(measure2).to_not be_conformant
      end
    end

    describe 'ME9' do
      context 'additional_code blank, goods nomenclature code blank' do
        let(:measure) { create :measure, additional_code_id: nil,
                                         goods_nomenclature_item_id: nil }

        it 'performs validation' do
          expect(measure).to_not be_conformant
        end
      end

      context 'additional_code present' do
        let(:measure) { create :measure, additional_code_id: '123' }

        it 'performs validation' do
          expect(measure).to be_conformant
        end
      end
    end

    describe 'ME10' do
      let(:measure1) { create :measure, :with_quota_order_number, order_number_capture_code: 1, ordernumber: nil }
      let(:measure2) { create :measure, :with_quota_order_number, order_number_capture_code: 2, ordernumber: '123' }
      let(:measure3) { create :measure, :with_quota_order_number, order_number_capture_code: 1, ordernumber: '123' }

      it 'performs validation' do
        expect(measure1).to_not be_conformant
        expect(measure2).to_not be_conformant
        expect(measure3).to     be_conformant
      end
    end

    describe 'ME12' do
      let(:measure1) { create :measure, :with_additional_code_type }
      let(:measure2) { create :measure, :with_related_additional_code_type }

      it 'performs validation' do
        expect(measure1).to_not be_conformant
        expect(measure2).to be_conformant
      end
    end

    describe 'ME13' do
      context 'additional code type meursing and attributes missing' do
        let(:measure) { create :measure, :with_related_additional_code_type,
                                        additional_code_type_id: 3,
                                        additional_code_id: '123',
                                        goods_nomenclature_item_id: nil,
                                        ordernumber: nil,
                                        reduction_indicator: nil }

        it 'should be valid' do
          expect(measure).to be_conformant
        end
      end

      context 'additional code type meursing and attributes present' do
        let(:measure) { create :measure, :with_related_additional_code_type,
                                         :with_quota_order_number,
                                        additional_code_type_id: 3,
                                        additional_code_id: '123',
                                        goods_nomenclature_item_id: '1234567890',
                                        ordernumber: '12345',
                                        reduction_indicator: 1 }

        it 'should no be valid' do
          expect(measure).to_not be_conformant
        end
      end

      context 'additional code type non meursing' do
        let(:measure) { create :measure, :with_related_additional_code_type,
                                        additional_code_type_id: 3 }

        it 'should be valid' do
          expect(measure).to be_conformant
        end
      end
    end

    describe 'ME14' do
      context 'additional code type meursing, additional code is associated to export refund nomenclature' do
        let(:additional_code) { create :additional_code, :with_export_refund_nomenclature }
        let(:measure) { create :measure, :with_related_additional_code_type,
                                         :with_quota_order_number,
                                        additional_code_type_id: 3,
                                        additional_code_id: additional_code.additional_code,
                                        goods_nomenclature_item_id: '1234567890',
                                        ordernumber: '12345',
                                        reduction_indicator: 1,
                                        order_number_capture_code: 1 }

        it 'should be valid' do
          expect(measure).to be_conformant
        end
      end

      context 'additional code type meursing, additional code is not associated to export refund nomenclature' do
        let(:additional_code) { create :additional_code }
        let(:measure) { create :measure, :with_related_additional_code_type,
                                         :with_quota_order_number,
                                        additional_code_type_id: 3,
                                        additional_code_id: additional_code.additional_code,
                                        goods_nomenclature_item_id: '1234567890',
                                        ordernumber: '12345',
                                        reduction_indicator: 1 }

        it 'should not be valid' do
          expect(measure).to_not be_conformant
        end
      end

      context 'additional code type non meursing' do
        let(:measure) { create :measure, :with_related_additional_code_type,
                                        additional_code_type_id: 3 }

        it 'should be valid' do
          expect(measure).to be_conformant
        end
      end
    end

    describe 'ME26' do
      it { should validate_exclusion.of([:measure_generating_regulation_id, :measure_generating_regulation_role])
                                    .from(->{ CompleteAbrogationRegulation.select(:complete_abrogation_regulation_id, :complete_abrogation_regulation_role) }) }
    end

    describe 'ME27' do
      let(:measure) { create :measure }

      context 'regulation fully replaced' do
        before { measure.generating_regulation.update(replacement_indicator: 1)}

        it 'should not be valid' do
          expect(measure.conformant?).to be_falsy
        end
      end

      context 'regulation partially replaced' do
        before { measure.generating_regulation.update(replacement_indicator: 2)}

        it 'should be valid' do
          expect(measure.conformant?).to be_truthy
        end
      end

      context 'regulation not replaced' do
        before { measure.generating_regulation.update(replacement_indicator: 0)}

        it 'should be valid' do
          expect(measure.conformant?).to be_truthy
        end
      end
    end

    describe 'ME33' do
      let(:measure) { create :measure, justification_regulation_id: nil,
                                      justification_regulation_role: nil }

      context 'measure validity end date is set' do
        before { measure.validity_end_date = Date.today }

        it 'performs validation' do
          expect(measure).to_not be_conformant
        end
      end

      context 'measure validity end date is not set' do
        before { measure.validity_end_date = nil }

        it 'performs validation' do
          expect(measure).to be_conformant
        end
      end
    end

    describe 'ME29' do
      context 'generating modification regulation abrogated' do
        let(:measure) { create :measure, :with_abrogated_modification_regulation }

        it 'performs validation' do
          expect(measure).to_not be_conformant
        end
      end

      context 'generating regulation is not modification regulation' do
        let(:measure) { create :measure }

        it 'performs validation' do
          expect(measure).to be_conformant
        end
      end
    end

    describe 'ME34' do
      let(:measure) { create :measure, justification_regulation_id: 'abc',
                                      justification_regulation_role: 1 }

      context 'measure validity end date is set' do
        before {
          measure.geographical_area.update(validity_end_date: Date.today.in(1.year))
          measure.measure_type.update(validity_end_date: Date.today.in(1.year))
          measure.goods_nomenclature.update(validity_end_date: Date.today.in(1.year))

          measure.validity_end_date = Date.today
        }

        it 'performs validation' do
          expect(measure).to be_conformant
        end
      end

      context 'measure validity end date is not set' do
        before { measure.validity_end_date = nil }

        it 'performs validation' do
          expect(measure).to_not be_conformant
        end
      end
    end

    describe 'ME86' do
      it { should validate_inclusion.of(:measure_generating_regulation_role).in(Measure::VALID_ROLE_TYPE_IDS) }
    end

    describe 'ME88' do
      let(:measure1) { create :measure, type_explosion_level: 10,
                                        gono_number_indents: 1 }
      let(:measure2) { create :measure, type_explosion_level: 1,
                                        gono_number_indents: 10 }

      it 'preforms validation' do
        expect(measure1).to be_conformant
        expect(measure2).to_not be_conformant
      end
    end

    describe 'ME116' do
      it { should validate_validity_date_span.of(:order_number) }
    end
  end

  describe '#origin' do
    before(:all) { Measure.unrestrict_primary_key }

    it 'should be uk' do
      expect(Measure.new(measure_sid: -1).origin).to eq "uk"
    end
    it 'should be eu' do
      expect(Measure.new(measure_sid: 1).origin).to eq "eu"
    end
  end

  describe "#measure_generating_regulation_id" do
    it 'reads measure generating regulation id from database' do
      measure = create :measure
      expect(measure.measure_generating_regulation_id).to_not be_blank
      expect(measure.measure_generating_regulation_id).to eq Measure.first.measure_generating_regulation_id
    end

    it 'measure D9500019 is globally replaced with D9601421' do
      measure = create :measure, measure_generating_regulation_id: "D9500019"
      expect(measure.measure_generating_regulation_id).to_not be_blank
      expect(measure.measure_generating_regulation_id).to eq "D9601421"
    end
  end

  describe "#order_number" do
    context "quota_order_number associated" do
      let(:quota_order_number) { create :quota_order_number }
      let(:measure) { create :measure, ordernumber: quota_order_number.quota_order_number_id }

      it 'should return associated quota order nmber' do
        expect(measure.order_number).to eq quota_order_number
      end
    end

    context "quota_order_number missing" do
      let(:ordernumber) { 6.times.map{ Random.rand(9) }.join }
      let(:measure) { create :measure, ordernumber: ordernumber }

      it 'should return a mock quota order number with just the number set' do
        expect(measure.order_number.quota_order_number_id).to eq ordernumber
      end

      it 'associated mock quota order number should have no quota definition' do
        expect(measure.order_number.quota_definition).to be_blank
      end
    end
  end

  describe "#import" do
    let(:measure) { create :measure, measure_type: measure_type }

    context 'measure type is import' do
      let(:measure_type) { create :measure_type, :import }

      it 'returns true' do
        expect(measure.import).to be_truthy
      end
    end

    context 'measure type is export' do
      let(:measure_type) { create :measure_type, :export }

      it 'returns false' do
        expect(measure.import).to be_falsy
      end
    end
  end

  describe "#export" do
    let(:measure) { create :measure, measure_type: measure_type }

    context 'measure type is import' do
      let(:measure_type) { create :measure_type, :import }

      it 'returns false' do
        expect(measure.export).to be_falsy
      end
    end

    context 'measure type is export' do
      let(:measure_type) { create :measure_type, :export }

      it 'returns true' do
        expect(measure.export).to be_truthy
      end
    end
  end

  describe '#generating_regulation_code' do
    let(:measure) {
      build :measure,
      measure_generating_regulation_id: '1234567'
    }

    it 'returns generating regulation code in TARIC format' do
      expect(measure.generating_regulation_code).to eq '14567/23'
    end
  end

  describe '#generating_regulation_url' do
    context 'when regulation was created between year 1970 and 2000' do
      let(:measure) {
        build :measure,
        measure_generating_regulation_id: '7734567'
      }

      it 'returns link to eur-lex with relevant year' do
        expect(measure.generating_regulation_url).to include '3197374567'
      end
    end

    context 'when regulation was created after year 2000' do
      let(:measure) {
        build :measure,
        measure_generating_regulation_id: '7014567'
      }

      it 'returns link to eur-lex with relevant year' do
        expect(measure.generating_regulation_url).to include '3200174567'
      end
    end
  end

  describe '#meursing?' do
    let(:measure) { create :measure }

    context 'any measure components are meursing' do
      let!(:measure_component) {
        create :measure_component,
          measure_sid: measure.measure_sid,
          duty_expression_id: DutyExpression::MEURSING_DUTY_EXPRESSION_IDS.sample
      }

      it 'returns true' do
        expect(measure).to be_meursing
      end
    end

    context 'no measure components are meursing' do
      let!(:measure_component) {
        create :measure_component,
          measure_sid: measure.measure_sid,
          duty_expression_id: 'aaa'
      }

      it 'returns false' do
        expect(measure).not_to be_meursing
      end
    end
  end

  describe '#national_measurement_units_for' do
    let(:measure_type) { create :measure_type, measure_type_description: measure_type_description }
    let(:measure)   { create :measure, measure_type_id: measure_type.measure_type_id }

    context 'measure is excise' do
      let(:measure_type_description) { 'EXCISE 111' }

      context 'declarable is passed in' do
        let(:commodity) { create :commodity }

        context 'declarable has national measurement unit set associated' do
          let(:tbl1) { create :tbl9, :unoq }
          let(:tbl2) { create :tbl9, :unoq }
          let!(:comm1) { create :comm, cmdty_code: commodity.goods_nomenclature_item_id,
                                      fe_tsmp: Date.today.ago(2.years),
                                      le_tsmp: nil,
                                      uoq_code_cdu2: tbl1.tbl_code,
                                      uoq_code_cdu3: tbl2.tbl_code }

          it 'returns national measurement unit names as a string array' do
            expect(measure.national_measurement_units_for(commodity).join).to match /#{Regexp.escape(tbl1.tbl_txt)}/i
            expect(measure.national_measurement_units_for(commodity).join).to match /#{Regexp.escape(tbl2.tbl_txt)}/i
          end
        end

        context 'declarable does not have national measurement unit set associated' do
          it 'returns blank result' do
            expect(measure.national_measurement_units_for(commodity)).to be_blank
          end
        end
      end

      context 'declarable is blank' do
        it 'returns blank result' do
          expect(measure.national_measurement_units_for(nil)).to be_blank
        end
      end
    end

    context 'measure is not excise' do
      let(:measure_type_description) { create :measure_type_description, description: 'not really e_x_c_i_s_e' }
      let(:measure_type) { create :measure_type, measure_type_id: measure_type_description.measure_type_id, measure_type_description: measure_type_description }
      let(:measure)   { create :measure, measure_type_id: measure_type.measure_type_id }

      it 'returns blank result' do
        expect(measure.national_measurement_units_for(nil)).to be_blank
      end
    end
  end

  describe '.changes_for' do
    context 'measure validity start date lower than requested date' do
      let!(:measure) { create :measure, validity_start_date: Date.new(2014,2,1) }

      it 'incudes measure' do
        TimeMachine.at(Date.new(2014,1,30)) do
          expect(Measure.changes_for).to be_empty
        end
      end
    end

    context 'measure validity start date higher than requested date' do
      let!(:measure) { create :measure, validity_start_date: Date.new(2014,2,1) }

      it 'does not include measure' do
        TimeMachine.at(Date.new(2014,2,1)) do
          expect(Measure.changes_for).not_to be_empty
          expect(Measure.changes_for.first.oid).to eq measure.source.oid
        end
      end
    end
  end

  describe "#duty_expression_with_national_measurement_units_for ^ #formatted_duty_expression_with_national_measurement_units_for" do
    let(:commodity) {
      create :commodity
    }
    let(:base) {
      measure.duty_expression_with_national_measurement_units_for(commodity)
    }
    let(:formatted_base) {
      measure.formatted_duty_expression_with_national_measurement_units_for(commodity)
    }
    let(:measure_type) {
      create :measure_type, :excise
    }
    let(:measure) {
      create :measure, measure_type_id: measure_type.measure_type_id
    }
    let(:duty_expression) {
      create(:duty_expression, :with_description)
    }
    let!(:measure_component) {
      create :measure_component, measure_sid: measure.measure_sid,
                                 duty_expression_id: duty_expression.duty_expression_id
    }

    context "without national_measurement_unit" do
      it {
        expect(base).to match Regexp.new(measure_component.duty_expression_str)
      }
      it {
        expect(formatted_base).to match Regexp.new(measure_component.formatted_duty_expression)
      }
    end

    context "with national_measurement_unit" do
      let!(:comm1) { create :comm, cmdty_code: commodity.goods_nomenclature_item_id,
                                   fe_tsmp: Date.today.ago(2.years),
                                   le_tsmp: nil,
                                   uoq_code_cdu2: tbl1.tbl_code,
                                   uoq_code_cdu3: tbl2.tbl_code }
      let(:tbl1) { create :tbl9, :unoq, tbl_code: 'aa1' }
      let(:tbl2) { create :tbl9, :unoq, tbl_code: 'aa2' }

      let(:national_measurement_units) {
        measure.national_measurement_units_for(commodity)
      }

      it {
        expect(base).to match Regexp.new(measure_component.duty_expression_str)
        national_measurement_units.each do |unit|
          expect(base).to match Regexp.new(unit)
        end
      }
      it {
        expect(formatted_base).to match Regexp.new(measure_component.formatted_duty_expression)
        national_measurement_units.each do |unit|
          expect(formatted_base).to match Regexp.new(unit)
        end
      }
    end
  end
end
