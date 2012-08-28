require 'spec_helper'

module Hdo
  describe VoteInferrer do
    it 'infers representatives from other votes the same day' do
      rep1 = Representative.make!
      rep2 = Representative.make!
      rep3 = Representative.make!
      rep4 = Representative.make!

      v1 = Vote.make!(
        :enacted      => true,
        :personal     => true,
        :time         => Time.parse("2012-08-07 12:56"),
        :vote_results => []
      )

      v1.vote_results.create! :representative => rep1, :result => 1
      v1.vote_results.create! :representative => rep2, :result => 0
      v1.vote_results.create! :representative => rep3, :result => -1
      v1.vote_results.create! :representative => rep4, :result => -1

      v2 = Vote.make!(
        :enacted      => false,
        :personal     => false,
        :time         => Time.parse("2012-08-07 13:20"),
        :vote_results => []
      )

      subject.infer!.should == [true]

      v2.reload

      # why can't we just do :representative => rep1 here?
      v2.vote_results.where(:representative_id => rep1.id).first.result.should == -1
      v2.vote_results.where(:representative_id => rep2.id).first.result.should == 0
      v2.vote_results.where(:representative_id => rep3.id).first.result.should == -1
      v2.vote_results.where(:representative_id => rep4.id).first.result.should == -1

      [v2.for_count, v2.against_count, v2.absent_count].should == [0, 3, 1]
    end

    it 'logs a message if results could not be inferred' do
      Vote.make!(
        :enacted      => true,
        :personal     => true,
        :time         => Time.parse("2012-08-07 12:56"),
      )

      Vote.make!(
        :enacted      => true,
        :personal     => false,
        :time         => Time.parse("2012-08-08 12:56"),
      )

      subject.log = mock(Logger)
      subject.log.should_receive(:info).with kind_of(String)

      subject.infer!.should == [false]
    end

    it 'ignores already inferred votes' do
      v = Vote.make!(
        :enacted      => true,
        :personal     => false
      )

      v.stub :inferred? => true

      described_class.new([v]).infer!.should == [false]
    end

    describe "with multiple voting sessions in the same day" do
      before do
        @rep1 = Representative.make!
        @rep2 = Representative.make!
        @rep3 = Representative.make!
        @rep4 = Representative.make!


        @personal_vote_in_other_cluster = Vote.make!(
          :enacted      => true,
          :personal     => true,
          :time         => Time.parse("2012-08-07 18:56"),
          :vote_results => []
        )

        @personal_vote_in_other_cluster.vote_results.create! :representative => @rep1, :result => 0
        @personal_vote_in_other_cluster.vote_results.create! :representative => @rep2, :result => 0
        @personal_vote_in_other_cluster.vote_results.create! :representative => @rep3, :result => 0
        @personal_vote_in_other_cluster.vote_results.create! :representative => @rep4, :result => -1

        @personal_vote_in_same_cluster = Vote.make!(
          :enacted      => true,
          :personal     => true,
          :time         => Time.parse("2012-08-07 12:56"),
          :vote_results => []
        )

        @personal_vote_in_same_cluster.vote_results.create! :representative => @rep1, :result => 1
        @personal_vote_in_same_cluster.vote_results.create! :representative => @rep2, :result => 0
        @personal_vote_in_same_cluster.vote_results.create! :representative => @rep3, :result => -1
        @personal_vote_in_same_cluster.vote_results.create! :representative => @rep4, :result => -1

        @non_personal_vote = Vote.make!(
          :enacted      => false,
          :personal     => false,
          :time         => Time.parse("2012-08-07 13:00"),
          :vote_results => []
        )

        subject.infer!.should == [true]

        @non_personal_vote.reload
      end

      it "infers the representatives from the personal vote of the same cluster" do

        # why can't we just do :representative => rep1 here?
        @non_personal_vote.vote_results.where(:representative_id => @rep1.id).first.result.should == -1
        @non_personal_vote.vote_results.where(:representative_id => @rep2.id).first.result.should == 0
        @non_personal_vote.vote_results.where(:representative_id => @rep3.id).first.result.should == -1
        @non_personal_vote.vote_results.where(:representative_id => @rep4.id).first.result.should == -1
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
        @rep1 = Representative.make!
        @rep2 = Representative.make!
        @rep3 = Representative.make!
        @rep4 = Representative.make!

        #cluster 1
        @first_cluster_votes = []
        10.times do |i|
          vote = Vote.make!(
            :enacted      => true,
            :personal     => true,
            :time         => Time.now + i.minutes,
            :vote_results => []
          )
          vote.vote_results.create! :representative => @rep1, :result => 0
          vote.vote_results.create! :representative => @rep2, :result => 1
          vote.vote_results.create! :representative => @rep3, :result => 1
          vote.vote_results.create! :representative => @rep4, :result => 1

          @first_cluster_votes << vote
        end

        #cluster 2
        @second_cluster_votes = []
        9.times do |i|
          vote = Vote.make!(
            :enacted      => true,
            :personal     => true,
            :time         => Time.now + 1.hour + i.minutes,
            :vote_results => []
          )
          vote.vote_results.create! :representative => @rep1, :result => -1
          vote.vote_results.create! :representative => @rep2, :result => 0
          vote.vote_results.create! :representative => @rep3, :result => 0
          vote.vote_results.create! :representative => @rep4, :result => -1

          @second_cluster_votes << vote
        end


        #cluster 3
        @third_cluster_votes = []
        8.times do |i|
          vote = Vote.make!(
            :enacted      => true,
            :personal     => true,
            :time         => Time.now + 2.hours + i.minutes,
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
        pending 'see https://github.com/holderdeord/hdo-site/issues/206'

        npv = Vote.make!(
          :enacted      => false,
          :personal     => false,
          :time         => Time.now,
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
          :enacted      => true,
          :personal     => false,
          :time         => Time.now + 1.hour,
          :vote_results => []
          )
        subject.infer!.should == [true]

        npv.reload

        npv.vote_results.where(:representative_id => @rep1.id).first.result.should == 1
        npv.vote_results.where(:representative_id => @rep2.id).first.result.should == 0
        npv.vote_results.where(:representative_id => @rep3.id).first.result.should == 0
        npv.vote_results.where(:representative_id => @rep4.id).first.result.should == 1

        npv.absent_count.should == 2
        npv.against_count.should == 0
        npv.for_count.should == 2
      end

      it "should put a non-personal vote that is two hours from now in the third cluster" do
        pending 'see https://github.com/holderdeord/hdo-site/issues/206'

        npv = Vote.make!(
          :enacted      => false,
          :personal     => false,
          :time         => Time.now + 2.hour,
          :vote_results => []
          )
        subject.infer!.should == [true]

        npv.reload

        npv.vote_results.where(:representative_id => @rep1.id).first.result.should == -1
        npv.vote_results.where(:representative_id => @rep2.id).first.result.should == -1
        npv.vote_results.where(:representative_id => @rep3.id).first.result.should == -1
        npv.vote_results.where(:representative_id => @rep4.id).first.result.should == -1

        npv.absent_count.should == 0
        npv.against_count.should == 4
        npv.for_count.should == 0
      end
    end
  end

end

