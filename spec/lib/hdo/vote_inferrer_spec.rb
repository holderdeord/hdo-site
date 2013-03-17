require 'spec_helper'

module Hdo
  describe VoteInferrer do
    it 'infers representatives from other votes the same day' do
      rep1 = Representative.make!
      rep2 = Representative.make!
      rep3 = Representative.make!
      rep4 = Representative.make!

      v1 = Vote.make!(
        enacted: true,
        personal: true,
        time: Time.parse("2012-08-07 12:56"),
        vote_results: []
      )

      v1.vote_results.create! representative: rep1, result: 1
      v1.vote_results.create! representative: rep2, result: 0
      v1.vote_results.create! representative: rep3, result: -1
      v1.vote_results.create! representative: rep4, result: -1

      v2 = Vote.make!(
        enacted: false,
        personal: false,
        time: Time.parse("2012-08-07 13:20"),
        vote_results: []
      )

      subject.infer!.should == [true]

      v2.reload

      # why can't we just do :representative => rep1 here?
      v2.vote_results.where(representative_id: rep1.id).first.result.should == -1
      v2.vote_results.where(representative_id: rep2.id).first.result.should == 0
      v2.vote_results.where(representative_id: rep3.id).first.result.should == -1
      v2.vote_results.where(representative_id: rep4.id).first.result.should == -1

      [v2.for_count, v2.against_count, v2.absent_count].should == [0, 3, 1]
    end

    it 'logs a message if results could not be inferred' do
      Vote.make!(
        enacted: true,
        personal: true,
        time: Time.parse("2012-08-07 12:56"),
      )

      Vote.make!(
        enacted: true,
        personal: false,
        time: Time.parse("2012-08-08 12:56"),
      )

      subject.log = mock(Logger)
      subject.log.should_receive(:info).with kind_of(String)

      subject.infer!.should == [false]
    end

    it 'ignores already inferred votes' do
      v = Vote.make!(
        enacted: true,
        personal: false
      )

      v.stub :inferred? => true

      described_class.new([v]).infer!.should == [false]
    end

    it 'removes duplicates from the given votes' do
      v1, v2 = Vote.make!(personal: false), Vote.make!(personal: false)

      vi = VoteInferrer.new([v1, v2, v1])
      vi.infer!.should == [false, false]
    end

    it 'picks the vote with the most representatives from the chosen cluster' do
      # Even though it's not really allowed, representatives sometimes forget to press the button.
      # When this happens, we want to pick the vote with the most representatives present to
      # have the inferred votes as accurate as possible.

      v1 = Vote.make!(
        enacted: true,
        personal: true,
        absent_count: 168,
        vote_results: [],
        time: Time.parse("2012-08-07 12:56")
      )


      v2 = Vote.make!(
        enacted: false,
        personal: true,
        absent_count: 167,
        vote_results: [],
        time: Time.parse("2012-08-07 12:57")
      )

      v3 = Vote.make!(
        enacted: true,
        personal: false,
        vote_results: [],
        time: Time.parse("2012-08-07 13:00")
      )

      vr1  = VoteResult.make!(representative: Representative.make!, result: 1, vote: v1)
      vr2a = VoteResult.make!(representative: Representative.make!, result: -1, vote: v2)
      vr2b = VoteResult.make!(representative: Representative.make!, result: 1, vote: v2)

      VoteInferrer.new([v3]).infer!.should == [true]
      v3.reload

      v3.vote_results.size.should == 2
    end

    describe "with multiple voting sessions in the same day" do
      before do
        @rep1 = Representative.make!
        @rep2 = Representative.make!
        @rep3 = Representative.make!
        @rep4 = Representative.make!


        @personal_vote_in_other_cluster = Vote.make!(
          enacted: true,
          personal: true,
          time: Time.parse("2012-08-07 18:56"),
          vote_results:  []
        )

        @personal_vote_in_other_cluster.vote_results.create! representative: @rep1, result: 0
        @personal_vote_in_other_cluster.vote_results.create! representative: @rep2, result: 0
        @personal_vote_in_other_cluster.vote_results.create! representative: @rep3, result: 0
        @personal_vote_in_other_cluster.vote_results.create! representative: @rep4, result: -1

        @personal_vote_in_same_cluster = Vote.make!(
          enacted: true,
          personal: true,
          time: Time.parse("2012-08-07 12:56"),
          vote_results: []
        )

        @personal_vote_in_same_cluster.vote_results.create! representative: @rep1, result: 1
        @personal_vote_in_same_cluster.vote_results.create! representative: @rep2, result: 0
        @personal_vote_in_same_cluster.vote_results.create! representative: @rep3, result: -1
        @personal_vote_in_same_cluster.vote_results.create! representative: @rep4, result: -1

        @non_personal_vote = Vote.make!(
          enacted: false,
          personal: false,
          time: Time.parse("2012-08-07 13:00"),
          vote_results:  []
        )

        subject.infer!.should == [true]

        @non_personal_vote.reload
      end

      it "infers the representatives from the personal vote of the same cluster" do
        # why can't we just do :representative => rep1 here?
        @non_personal_vote.vote_results.where(representative_id: @rep1.id).first.result.should == -1
        @non_personal_vote.vote_results.where(representative_id: @rep2.id).first.result.should == 0
        @non_personal_vote.vote_results.where(representative_id: @rep3.id).first.result.should == -1
        @non_personal_vote.vote_results.where(representative_id: @rep4.id).first.result.should == -1
      end

      it "infers that the non-personal fote has 3 votes against" do
        @non_personal_vote.against_count.should == 3
      end

      it "should infer 1 absent voter" do
        @non_personal_vote.absent_count.should == 1
      end

      it "should infer 0 for votes" do
        @non_personal_vote.for_count.should == 0
      end
    end

    describe "with a whole bunch of votes in 3 clusters" do
      before do
        @now = Time.current

        @rep1 = Representative.make!
        @rep2 = Representative.make!
        @rep3 = Representative.make!
        @rep4 = Representative.make!

        #cluster 1
        @first_cluster_votes = []
        10.times do |i|
          vote = Vote.make!(
            enacted: true,
            personal: true,
            time: @now + i.minutes,
            vote_results: []
          )

          vote.vote_results.create! representative: @rep1, result: 0
          vote.vote_results.create! representative: @rep2, result: 1
          vote.vote_results.create! representative: @rep3, result: 1
          vote.vote_results.create! representative: @rep4, result: 1

          @first_cluster_votes << vote
        end

        #cluster 2
        @second_cluster_votes = []
        9.times do |i|
          vote = Vote.make!(
            enacted: true,
            personal: true,
            time: @now + 1.hour + i.minutes,
            vote_results: []
          )

          vote.vote_results.create! representative: @rep1, result: -1
          vote.vote_results.create! representative: @rep2, result: 0
          vote.vote_results.create! representative: @rep3, result: 0
          vote.vote_results.create! representative: @rep4, result: -1

          @second_cluster_votes << vote
        end


        #cluster 3
        @third_cluster_votes = []
        8.times do |i|
          vote = Vote.make!(
            :enacted      => true,
            :personal     => true,
            :time         => @now + 2.hours + i.minutes,
            :vote_results => []
            )
          vote.vote_results.create! :representative => @rep1, :result => 1
          vote.vote_results.create! :representative => @rep2, :result => 1
          vote.vote_results.create! :representative => @rep3, :result => -1
          vote.vote_results.create! :representative => @rep4, :result => -1

          @third_cluster_votes << vote
        end
      end

      it "should put a non-personal vote that is now in the first cluster" do
        npv = Vote.make!(
          :enacted      => false,
          :personal     => false,
          :time         => @now + 1.second,
          :vote_results => []
        )

        subject.infer!.should == [true]

        npv.reload

        npv.vote_results.where(:representative_id => @rep1.id).first.result.should == 0
        npv.vote_results.where(:representative_id => @rep2.id).first.result.should == -1
        npv.vote_results.where(:representative_id => @rep3.id).first.result.should == -1
        npv.vote_results.where(:representative_id => @rep4.id).first.result.should == -1

        npv.absent_count.should == 1
        npv.against_count.should == 3
        npv.for_count.should == 0
      end

      it "should put a non-personal vote that is an hour from now in the second cluster" do
        npv = Vote.make!(
          enacted: true,
          personal: false,
          time: @now + 1.hour + 1.second,
          vote_results: []
        )
        subject.infer!.should == [true]

        npv.reload

        npv.vote_results.where(representative_id: @rep1.id).first.result.should == 1
        npv.vote_results.where(representative_id: @rep2.id).first.result.should == 0
        npv.vote_results.where(representative_id: @rep3.id).first.result.should == 0
        npv.vote_results.where(representative_id: @rep4.id).first.result.should == 1

        npv.absent_count.should == 2
        npv.against_count.should == 0
        npv.for_count.should == 2
      end

      it "should put a non-personal vote that is two hours from now in the third cluster" do
        npv = Vote.make!(
          enacted: false,
          personal: false,
          time: @now + 2.hour + 1.second,
          vote_results: []
        )
        subject.infer!.should == [true]

        npv.reload

        npv.vote_results.where(representative_id: @rep1.id).first.result.should == -1
        npv.vote_results.where(representative_id: @rep2.id).first.result.should == -1
        npv.vote_results.where(representative_id: @rep3.id).first.result.should == -1
        npv.vote_results.where(representative_id: @rep4.id).first.result.should == -1

        npv.absent_count.should == 0
        npv.against_count.should == 4
        npv.for_count.should == 0
      end
    end

    describe "with the real world data of 2012-06-14" do
      before do
        rep = Representative.make!

        personal_votes = [
          # timestamp,            enacted
          ['2012-06-14 20:32:07', true],
          ['2012-06-14 20:32:50', true],
          ['2012-06-14 20:32:50', false],
          ['2012-06-14 20:33:23', true],
          ['2012-06-14 20:33:49', true],
          ['2012-06-14 20:34:11', true],
          ['2012-06-14 20:34:36', true],
          ['2012-06-14 20:35:11', true],
          ['2012-06-14 20:36:44', true],
          ['2012-06-14 20:36:44', false],
          ['2012-06-14 20:38:39', true],
          ['2012-06-14 20:40:21', true],
          ['2012-06-14 20:40:48', true],
          ['2012-06-14 20:41:11', true],
          ['2012-06-14 20:42:22', true],
          ['2012-06-14 20:42:51', true],
          ['2012-06-14 20:43:17', true],
          ['2012-06-14 20:43:36', true],
          ['2012-06-14 20:44:02', true],
          ['2012-06-14 20:44:35', true],
          ['2012-06-14 20:45:16', true],
          ['2012-06-14 20:45:38', true],
          ['2012-06-14 20:46:05', true],
          ['2012-06-14 20:46:31', true],
          ['2012-06-14 20:46:31', false],
          ['2012-06-14 20:47:05', true],
          ['2012-06-14 20:47:24', true],
          ['2012-06-14 20:47:55', true],
          ['2012-06-14 20:49:11', true],
          ['2012-06-14 20:49:11', false],
        ]

          personal_votes.each do |t, enacted|
            Vote.make!(
              enacted: enacted,
              personal: true,
              time: Time.parse(t),
              vote_results: [VoteResult.create!(representative: rep, result: 1)]
            )
          end

          non_personal_votes = [
            '2012-06-14 20:33:09',
            '2012-06-14 20:35:35',
            '2012-06-14 20:35:54',
            '2012-06-14 20:37:11',
            '2012-06-14 20:37:27',
            '2012-06-14 20:37:46',
            '2012-06-14 20:38:13',
            '2012-06-14 20:39:03',
            '2012-06-14 20:48:20',
            '2012-06-14 20:49:33',
            '2012-06-14 20:50:30',
            '2012-06-14 20:51:20',
          ]

          @non_personal_votes = non_personal_votes.map do |t|
            Vote.make!(
              enacted: true,
              personal: false,
              time: t,
              vote_results: []
            )
          end
        end

        it "doesn't fail" do
          subject.infer!.should == [true, true, true, true, true, true, true, true, true, true, true, true]
        end

        it "infers the correct resuls for those votes" do
          subject.infer!
          @non_personal_votes.each do |npv|
            npv.reload

            npv.should be_inferred
            npv.for_count.should == 1
          end
        end
      end
    end

  end
