# encoding: utf-8
require './lib/hdo/utils/proposition_source_guesser'

module Hdo
  module Utils
    describe PropositionSourceGuesser do
      let(:g) { PropositionSourceGuesser }

      it 'finds parties regardless of case' do
        g.parties_for('arbeiderpartiet').should == ['A']
        g.parties_for('ArbeiderpartieT').should == ['A']
        g.parties_for('Venstre').should == ['V']
        g.parties_for('Rødt').should == ['R']
      end

      it 'finds new norwegian names' do
        g.parties_for('arbeidarpartiet').should == ['A']
        g.parties_for('framstegspartiet').should == ['FrP']
        g.parties_for('kristeleg folkeparti').should == ['KrF']
        g.parties_for('høgre').should == ['H']
        g.parties_for('raudt').should == ['R']
      end

      it 'finds shorthand parties' do
        g.parties_for('a').should == ['A']
        g.parties_for('ap').should == ['A']
        g.parties_for('krf').should == ['KrF']
        g.parties_for('frp').should == ['FrP']
        g.parties_for('r').should == ['R']
      end

      it 'looks at boundaries' do
        g.parties_for('sosialistisk venstreparti').should_not include("V")
        g.parties_for('rød valgallianse').should_not include("R")
      end

      it 'ignores "bokstav" and "romertall"' do
        g.parties_for('Komiteens tilråding bokstav A. rammeområde 1, romertall V.').should be_empty
      end

    end
  end
end
