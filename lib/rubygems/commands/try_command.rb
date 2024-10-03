require "irb"

class Gem::Commands::TryCommand < Gem::Command
  def initialize
    super("try", "Spin up an IRB-session with gems loaded")

    add_option "--print", "print the inline-gemfile, then exit" do |value, options|
      options[:print] = true
    end
  end

  def execute
    if options[:args].any?
      gemfile = render_inline_gemfile(parse_args(options[:args]))

      if options[:print]
        puts gemfile
      else
        written_gemfile = Tempfile.new(%w[inline_gemfile .rb]).tap do |file|
          file.write(gemfile)
          file.rewind
        end
        ARGV.clear
        ARGV << "-r#{written_gemfile.path}"
        IRB.start
      end
    else
      ARGV.clear
      IRB.start unless options[:print]
    end
  ensure
    if written_gemfile
      written_gemfile.close
      written_gemfile.unlink
    end
  end

  def usage # :nodoc:
    "#{program_name} [some-gem[:some/require][@version]] [some-gem ...]"
  end

  def description
    <<~DESC

      Examples usage:

        # Provide zero or more gems and it's off to the races:
        $ gem try rails sqlite3
        irb(main):001> ActiveRecord::Base.establish_connection(adapter: :sqlite3, database: ':memory:')
        irb(main):002> ActiveRecord::Base.connection.select_all('select 1')

        # Versions
        #
        # Any version provided is prepended with '~> ' (most common, saves
        # typing and quoting).
        # So this:
        $ gem try rails@7.2
        # ...is as if you typed:
        $ gem try rails@'~>7.2'
        # Prepend with '=' to get exact version:
        $ gem try rails@=7.2.1

        # Requires
        #
        # If you need a require that differs from the gem-name:
        $ gem try dotenv:dotenv/load@'~> 2'

        # For e.g. rails, activesupport etc. special requires are baked in.
        # So e.g. instead of this:
        $ gem try activesupport:active_support/all

        # ...this suffices:
        $ gem try activesupport
        irb(main):001> [:cat].inquiry.cat?
        => true

        # To prevent require (require: false)
        $ gem try rails:

        # Debug
        #
        # See what inline gemfile is generated using print:
        $ gem try --print activerecord sqlite3
    DESC
  end

  def parse_args(args)
    args.map do |item|
      /(?<gem>[^:@]+)(?::(?<require>[^@]*))?(?:@(?<version>.+))?/.match(item)&.values_at(:gem, :require, :version)
    end.map do |(gem, req, version)|
      req = req&.empty? ? false : (req || predefined_requires_by_gem[gem] || gem)
      version = case version
      when /^\d/ then "~>#{version}"
      else
        version
      end

      [gem, req, version]
    end
  end

  def predefined_requires_by_gem
    {"rails" => "rails/all",
     "activerecord" => "active_record",
     "activesupport" => "active_support/all"}
  end

  def render_inline_gemfile(parsed)
    require "erb"
    ERB.new(<<~GEMFILE, trim_mode: "-").result(binding)
      require "bundler/inline"

      gemfile(true) do
        source "https://rubygems.org"

      <% parsed.each do |gem,req,ver| -%>
        gem <%= gem.inspect %>, <%= ver ? ver.inspect << ", " : '' %>require: <%= req.inspect %>
      <% end -%>
      end
    GEMFILE
  end
end
