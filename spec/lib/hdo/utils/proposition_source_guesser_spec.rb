require './lib/hdo/utils/proposition_source_guesser'

module Hdo
  module Utils
    describe PropositionSourceGuesser do
      let(:g) { PropositionSourceGuesser }

      it 'finds parties regardless of case' do
        g.parties_for('arbeiderpartiet').should == ['A']
        g.parties_for('ArbeiderpartieT').should == ['A']
        g.parties_for('Venstre').should == ['V']
      end

      it 'finds shorthand parties' do
        g.parties_for('a').should == ['A']
        g.parties_for('ap').should == ['A']
        g.parties_for('krf').should == ['KrF']
        g.parties_for('frp').should == ['FrP']
      end

      it 'looks at boundaries' do
        g.parties_for('sosialistisk venstreparti').should_not include("V")
      end

    end
  end
end
