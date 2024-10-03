class Gem::Commands::TryCommand < Gem::Command
  def initialize
    super 'try', 'Spin up an IRB-session with gems loaded'
  end
end
