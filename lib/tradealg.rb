class Tradealg
  attr_reader :operations

  def initialize(operations)
    @operations = setup_operations(operations)
  end

  # This method returns a report with all the available metrics.
  REPORT_EXCLUSIONS = %i[report].freeze # list of public methods to exclude from the report
  def report
    report = {}

    # call all public methods that return a value
    self.class.instance_methods(false).each do |method|
      next if REPORT_EXCLUSIONS.include?(method)

      begin
        report[method] = send(method)
      rescue ArgumentError => e
        report[method] = e.message
      end
    end

    report
  end

  # PROFIT FACTOR METHODS
  ####################################################################################################################

  # This function returns the profit factor history of the system.
  # The profit factor is calculated by dividing the sum of all winning operations by the sum of all losing operations.
  # The profit factor history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The profit factor of the system at that timestamp.
  # NOTE: In case of no losing operations, the profit factor is set to 999999.
  def profit_factor_history
    return @profit_factor_history if defined? @profit_factor_history

    @profit_factor_history = []

    sum_of_win_operations = 0
    sum_of_loss_operations = 0
    @operations.each do |operation|
      next unless %i[buy sell].include?(operation[:type])

      operation[:value].positive? ? sum_of_win_operations += operation[:value] : sum_of_loss_operations += operation[:value]
      profit_factor = sum_of_loss_operations.zero? ? 999_999 : sum_of_win_operations / sum_of_loss_operations.abs
      @profit_factor_history << { timestamp: operation[:timestamp], value: profit_factor }
    end

    @profit_factor_history
  end

  # This function return the profit factor of the system at a given timestamp.
  def profit_factor_at(timestamp = Time.now)
    last_profit_factor = 0

    profit_factor_history.each do |profit_factor|
      break if profit_factor[:timestamp] > timestamp
      last_profit_factor = profit_factor[:value]
    end

    last_profit_factor
  end

  # This function returns the highest profit factor of the system between two timestamps.
  # If no timestamps are provided, it will return the highest profit factor of the system.
  def highest_profit_factor_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_profit_factor = nil

    profit_factor_history.each do |profit_factor|
      break if profit_factor[:timestamp] > end_time
      next if profit_factor[:timestamp] < start_time

      highest_profit_factor = profit_factor[:value] if highest_profit_factor.nil? || profit_factor[:value] > highest_profit_factor
    end

    highest_profit_factor
  end

  # This function returns the lowest profit factor of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest profit factor of the system.
  def lowest_profit_factor_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_profit_factor = nil

    profit_factor_history.each do |profit_factor|
      break if profit_factor[:timestamp] > end_time
      next if profit_factor[:timestamp] < start_time

      lowest_profit_factor = profit_factor[:value] if lowest_profit_factor.nil? || profit_factor[:value] < lowest_profit_factor
    end

    lowest_profit_factor
  end

  # This function returns the average profit factor of the system between two timestamps.
  # If no timestamps are provided, it will return the average profit factor of the system.
  def average_profit_factor_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_profit_factor = 0
    total_operations = 0

    profit_factor_history.each do |profit_factor|
      break if profit_factor[:timestamp] > end_time
      next if profit_factor[:timestamp] < start_time

      total_profit_factor += profit_factor[:value]
      total_operations += 1
    end

    total_profit_factor / total_operations
  end

  # WIN RATE PERC METHODS
  ####################################################################################################################

  # This function returns the win rate percentage history of the system.
  # The win rate percentage is calculated by dividing the number of win operations by the total number of operations.
  # The win rate percentage history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The win rate percentage of the system at that timestamp.
  def win_rate_perc_history
    return @win_rate_perc_history if defined? @win_rate_perc_history

    @win_rate_perc_history = []

    number_of_win_operations = 0
    number_of_loss_operations = 0
    @operations.each do |operation|
      next unless %i[buy sell].include?(operation[:type])

      operation[:value].positive? ? number_of_win_operations += 1 : number_of_loss_operations += 1
      win_rate_perc = number_of_win_operations.zero? && number_of_loss_operations.zero? ? 0 : number_of_win_operations * 100.0 / (number_of_win_operations + number_of_loss_operations)
      @win_rate_perc_history << { timestamp: operation[:timestamp], value: win_rate_perc }
    end

    @win_rate_perc_history
  end

  # This function return the win rate percentage of the system at a given timestamp.
  def win_rate_perc_at(timestamp = Time.now)
    last_win_rate_perc = 0

    win_rate_perc_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > timestamp
      last_win_rate_perc = win_rate_perc[:value]
    end

    last_win_rate_perc
  end

  # This function returns the highest win rate percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the highest win rate percentage of the system.
  def highest_win_rate_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_win_rate_perc = nil

    win_rate_perc_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      highest_win_rate_perc = win_rate_perc[:value] if highest_win_rate_perc.nil? || win_rate_perc[:value] > highest_win_rate_perc
    end

    highest_win_rate_perc
  end

  # This function returns the lowest win rate percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest win rate percentage of the system.
  def lowest_win_rate_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_win_rate_perc = nil

    win_rate_perc_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      lowest_win_rate_perc = win_rate_perc[:value] if lowest_win_rate_perc.nil? || win_rate_perc[:value] < lowest_win_rate_perc
    end

    lowest_win_rate_perc
  end

  # This function returns the average win rate percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the average win rate percentage of the system.
  def average_win_rate_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_win_rate_perc = 0
    total_operations = 0

    win_rate_perc_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      total_win_rate_perc += win_rate_perc[:value]
      total_operations += 1
    end

    total_win_rate_perc / total_operations
  end

  # SAME METHODS BUT FOR LONG HISTORY

  def win_rate_perc_long_history
    return @win_rate_perc_long_history if defined? @win_rate_perc_long_history

    @win_rate_perc_long_history = []

    number_of_win_operations = 0
    number_of_loss_operations = 0
    @operations.each do |operation|
      next unless operation[:type] == :buy

      operation[:value].positive? ? number_of_win_operations += 1 : number_of_loss_operations += 1
      win_rate_perc = number_of_win_operations.zero? && number_of_loss_operations.zero? ? 0 : number_of_win_operations * 100.0 / (number_of_win_operations + number_of_loss_operations)
      @win_rate_perc_long_history << { timestamp: operation[:timestamp], value: win_rate_perc }
    end

    @win_rate_perc_long_history
  end

  def win_rate_perc_long_at(timestamp = Time.now)
    last_win_rate_perc = 0

    win_rate_perc_long_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > timestamp
      last_win_rate_perc = win_rate_perc[:value]
    end

    last_win_rate_perc
  end

  def highest_win_rate_perc_long_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_win_rate_perc = nil

    win_rate_perc_long_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      highest_win_rate_perc = win_rate_perc[:value] if highest_win_rate_perc.nil? || win_rate_perc[:value] > highest_win_rate_perc
    end

    highest_win_rate_perc
  end

  def lowest_win_rate_perc_long_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_win_rate_perc = nil

    win_rate_perc_long_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      lowest_win_rate_perc = win_rate_perc[:value] if lowest_win_rate_perc.nil? || win_rate_perc[:value] < lowest_win_rate_perc
    end

    lowest_win_rate_perc
  end

  def average_win_rate_perc_long_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_win_rate_perc = 0
    total_operations = 0

    win_rate_perc_long_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      total_win_rate_perc += win_rate_perc[:value]
      total_operations += 1
    end

    total_win_rate_perc / total_operations
  end

  # SAME METHODS BUT FOR SHORT HISTORY

  def win_rate_perc_short_history
    return @win_rate_perc_short_history if defined? @win_rate_perc_short_history

    @win_rate_perc_short_history = []

    number_of_win_operations = 0
    number_of_loss_operations = 0
    @operations.each do |operation|
      next unless operation[:type] == :sell

      operation[:value].positive? ? number_of_win_operations += 1 : number_of_loss_operations += 1
      win_rate_perc = number_of_win_operations.zero? && number_of_loss_operations.zero? ? 0 : number_of_win_operations * 100.0 / (number_of_win_operations + number_of_loss_operations)
      @win_rate_perc_short_history << { timestamp: operation[:timestamp], value: win_rate_perc }
    end

    @win_rate_perc_short_history
  end

  def win_rate_perc_short_at(timestamp = Time.now)
    last_win_rate_perc = 0

    win_rate_perc_short_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > timestamp
      last_win_rate_perc = win_rate_perc[:value]
    end

    last_win_rate_perc
  end

  def highest_win_rate_perc_short_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_win_rate_perc = nil

    win_rate_perc_short_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      highest_win_rate_perc = win_rate_perc[:value] if highest_win_rate_perc.nil? || win_rate_perc[:value] > highest_win_rate_perc
    end

    highest_win_rate_perc
  end

  def lowest_win_rate_perc_short_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_win_rate_perc = nil

    win_rate_perc_short_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      lowest_win_rate_perc = win_rate_perc[:value] if lowest_win_rate_perc.nil? || win_rate_perc[:value] < lowest_win_rate_perc
    end

    lowest_win_rate_perc
  end

  def average_win_rate_perc_short_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_win_rate_perc = 0
    total_operations = 0

    win_rate_perc_short_history.each do |win_rate_perc|
      break if win_rate_perc[:timestamp] > end_time
      next if win_rate_perc[:timestamp] < start_time

      total_win_rate_perc += win_rate_perc[:value]
      total_operations += 1
    end

    total_win_rate_perc / total_operations
  end

  # EXPECTANCY METHODS
  ####################################################################################################################

  # This function returns the expectancy history of the system.
  # The expectancy is calculated by multiplying the average win by the win rate and subtracting the average loss by the loss rate.
  # The expectancy history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The expectancy of the system at that timestamp.
  def expectancy_history
    return @expectancy_history if defined? @expectancy_history

    @expectancy_history = []

    count_win = 0
    count_loss = 0
    value_win = 0
    value_loss = 0
    operations.each do |operation|
      next unless %i[buy sell].include?(operation[:type])

      if operation[:value].positive?
        count_win += 1
        value_win += operation[:value]
      else
        count_loss += 1
        value_loss += operation[:value]
      end

      win_rate = count_win.zero? && count_loss.zero? ? 0 : count_win * 100.0 / (count_win + count_loss)
      loss_rate = 100 - win_rate
      avg_win = count_win.zero? ? 0 : value_win / count_win
      avg_loss = count_loss.zero? ? 0 : value_loss / count_loss
      expectancy = (avg_win * win_rate / 100) - (avg_loss * loss_rate / 100)
      @expectancy_history << { timestamp: operation[:timestamp], value: expectancy }
    end

    @expectancy_history
  end

  # This function return the expectancy of the system at a given timestamp.
  def expectancy_at(timestamp = Time.now)
    last_expectancy = 0

    expectancy_history.each do |expectancy|
      break if expectancy[:timestamp] > timestamp
      last_expectancy = expectancy[:value]
    end

    last_expectancy
  end

  # This function returns the highest expectancy of the system between two timestamps.
  # If no timestamps are provided, it will return the highest expectancy of the system.
  def highest_expectancy_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_expectancy = nil

    expectancy_history.each do |expectancy|
      break if expectancy[:timestamp] > end_time
      next if expectancy[:timestamp] < start_time

      highest_expectancy = expectancy[:value] if highest_expectancy.nil? || expectancy[:value] > highest_expectancy
    end

    highest_expectancy
  end

  # This function returns the lowest expectancy of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest expectancy of the system.
  def lowest_expectancy_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_expectancy = nil

    expectancy_history.each do |expectancy|
      break if expectancy[:timestamp] > end_time
      next if expectancy[:timestamp] < start_time

      lowest_expectancy = expectancy[:value] if lowest_expectancy.nil? || expectancy[:value] < lowest_expectancy
    end

    lowest_expectancy
  end

  # This function returns the average expectancy of the system between two timestamps.
  # If no timestamps are provided, it will return the average expectancy of the system.
  def average_expectancy_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_expectancy = 0
    total_operations = 0

    expectancy_history.each do |expectancy|
      break if expectancy[:timestamp] > end_time
      next if expectancy[:timestamp] < start_time

      total_expectancy += expectancy[:value]
      total_operations += 1
    end

    total_expectancy / total_operations
  end

  # CONSISTENCY PERC METHODS
  ####################################################################################################################

  # This function returns the consistency percentage history of the system.
  # The consistency percentage is calculated by dividing the sum of all trading days by the highest trading day.
  # The consistency percentage history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The consistency percentage of the system at that timestamp.
  def consistency_perc_history
    return @consistency_history if defined? @consistency_history

    @consistency_history = []

    operations_per_day = {}
    operations.each do |operation|
      next unless %i[buy sell].include?(operation[:type])

      date = operation[:timestamp].to_date
      operations_per_day[date] ||= []
      operations_per_day[date] << operation
    end

    sum_of_trading_days = 0
    max_trading_days = 0
    operations_per_day.each_value do |daily_operations|
      sum_of_trading_day = daily_operations.sum { |operation| operation[:value] }
      max_trading_days = sum_of_trading_day if sum_of_trading_day > max_trading_days
      sum_of_trading_days += sum_of_trading_day.abs

      daily_consistency = sum_of_trading_days.zero? ? 0 : (1 - (max_trading_days / sum_of_trading_days)) * 100
      @consistency_history << { timestamp: daily_operations.first[:timestamp], value: daily_consistency }
    end

    @consistency_history
  end

  # This function return the consistency percentage of the system at a given timestamp.
  def consistency_perc_at(timestamp = Time.now)
    last_consistency_perc = 0

    consistency_perc_history.each do |consistency_perc|
      break if consistency_perc[:timestamp] > timestamp
      last_consistency_perc = consistency_perc[:value]
    end

    last_consistency_perc
  end

  # This function returns the highest consistency percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the highest consistency percentage of the system.
  def highest_consistency_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_consistency_perc = nil

    consistency_perc_history.each do |consistency_perc|
      break if consistency_perc[:timestamp] > end_time
      next if consistency_perc[:timestamp] < start_time

      highest_consistency_perc = consistency_perc[:value] if highest_consistency_perc.nil? || consistency_perc[:value] > highest_consistency_perc
    end

    highest_consistency_perc
  end

  # This function returns the lowest consistency percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest consistency percentage of the system.
  def lowest_consistency_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_consistency_perc = nil

    consistency_perc_history.each do |consistency_perc|
      break if consistency_perc[:timestamp] > end_time
      next if consistency_perc[:timestamp] < start_time

      lowest_consistency_perc = consistency_perc[:value] if lowest_consistency_perc.nil? || consistency_perc[:value] < lowest_consistency_perc
    end

    lowest_consistency_perc
  end

  # This function returns the average consistency percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the average consistency percentage of the system.
  def average_consistency_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_consistency_perc = 0
    total_operations = 0

    consistency_perc_history.each do |consistency_perc|
      break if consistency_perc[:timestamp] > end_time
      next if consistency_perc[:timestamp] < start_time

      total_consistency_perc += consistency_perc[:value]
      total_operations += 1
    end

    total_consistency_perc / total_operations
  end

  # DRAWDOWN PERC METHODS
  ####################################################################################################################

  # This function returns the drawdown percentage history of the system.
  # The drawdown percentage is calculated by dividing the drawdown by the highest balance.
  # The drawdown percentage history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The drawdown percentage of the system at that timestamp.
  def drawdown_perc_history
    return @drawdown_perc_history if defined? @drawdown_perc_history

    @drawdown_perc_history = []
    highest_balance = 0

    balance_history.each do |balance|
      highest_balance = balance[:value] if balance[:value] > highest_balance
      drawdown = highest_balance - balance[:value]
      drawdown_perc = highest_balance.zero? ? 0 : drawdown * 100 / highest_balance
      @drawdown_perc_history << { timestamp: balance[:timestamp], value: drawdown_perc }
    end

    @drawdown_perc_history
  end

  # This function return the drawdown percentage of the system at a given timestamp.
  def drawdown_perc_at(timestamp = Time.now)
    last_drawdown_perc = 0

    drawdown_perc_history.each do |drawdown_perc|
      break if drawdown_perc[:timestamp] > timestamp
      last_drawdown_perc = drawdown_perc[:value]
    end

    last_drawdown_perc
  end

  # This function returns the highest drawdown percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the highest drawdown percentage of the system.
  def highest_drawdown_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_drawdown_perc = nil

    drawdown_perc_history.each do |drawdown_perc|
      break if drawdown_perc[:timestamp] > end_time
      next if drawdown_perc[:timestamp] < start_time

      highest_drawdown_perc = drawdown_perc[:value] if highest_drawdown_perc.nil? || drawdown_perc[:value] > highest_drawdown_perc
    end

    highest_drawdown_perc
  end

  # This function returns the lowest drawdown percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest drawdown percentage of the system.
  def lowest_drawdown_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_drawdown_perc = nil

    drawdown_perc_history.each do |drawdown_perc|
      break if drawdown_perc[:timestamp] > end_time
      next if drawdown_perc[:timestamp] < start_time

      lowest_drawdown_perc = drawdown_perc[:value] if lowest_drawdown_perc.nil? || drawdown_perc[:value] < lowest_drawdown_perc
    end

    lowest_drawdown_perc
  end

  # This function returns the average drawdown percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the average drawdown percentage of the system.
  def average_drawdown_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_drawdown_perc = 0
    total_operations = 0

    drawdown_perc_history.each do |drawdown_perc|
      break if drawdown_perc[:timestamp] > end_time
      next if drawdown_perc[:timestamp] < start_time

      total_drawdown_perc += drawdown_perc[:value]
      total_operations += 1
    end

    total_drawdown_perc / total_operations
  end

  # DRAWDOWN METHODS
  ####################################################################################################################

  # This function returns the drawdown history of the system.
  # The drawdown is calculated by subtracting the balance from the highest balance.
  # The drawdown history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The drawdown of the system at that timestamp.
  def drawdown_history
    return @drawdown_history if defined? @drawdown_history

    @drawdown_history = []
    highest_balance = 0

    balance_history.each do |balance|
      highest_balance = balance[:value] if balance[:value] > highest_balance
      drawdown = highest_balance - balance[:value]
      @drawdown_history << { timestamp: balance[:timestamp], value: drawdown }
    end

    @drawdown_history
  end

  # This function return the drawdown of the system at a given timestamp.
  def drawdown_at(timestamp = Time.now)
    last_drawdown = 0

    drawdown_history.each do |drawdown|
      break if drawdown[:timestamp] > timestamp
      last_drawdown = drawdown[:value]
    end

    last_drawdown
  end

  # This function returns the highest drawdown of the system between two timestamps.
  # If no timestamps are provided, it will return the highest drawdown of the system.
  def highest_drawdown_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_drawdown = nil

    drawdown_history.each do |drawdown|
      break if drawdown[:timestamp] > end_time
      next if drawdown[:timestamp] < start_time

      highest_drawdown = drawdown[:value] if highest_drawdown.nil? || drawdown[:value] > highest_drawdown
    end

    highest_drawdown
  end

  # This function returns the lowest drawdown of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest drawdown of the system.
  def lowest_drawdown_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_drawdown = nil

    drawdown_history.each do |drawdown|
      break if drawdown[:timestamp] > end_time
      next if drawdown[:timestamp] < start_time

      lowest_drawdown = drawdown[:value] if lowest_drawdown.nil? || drawdown[:value] < lowest_drawdown
    end

    lowest_drawdown
  end

  # This function returns the average drawdown of the system between two timestamps.
  # If no timestamps are provided, it will return the average drawdown of the system.
  def average_drawdown_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_drawdown = 0
    total_operations = 0

    drawdown_history.each do |drawdown|
      break if drawdown[:timestamp] > end_time
      next if drawdown[:timestamp] < start_time

      total_drawdown += drawdown[:value]
      total_operations += 1
    end

    total_drawdown / total_operations
  end

  # GAIN PERC METHODS
  ####################################################################################################################

  # This function returns the gain percentage history of the system.
  # The gain percentage is calculated by summing all the operations of type :buy and :sell and dividing it by the deposit operations at that timestamp.
  # The gain percentage history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The gain percentage of the system at that timestamp.
  def gain_perc_history
    return @gain_perc_history if defined? @gain_perc_history

    @gain_perc_history = []
    gain = 0
    deposit = 0

    @operations.each do |operation|
      deposit += operation[:value] if [:deposit, :withdraw].include?(operation[:type])
      next unless [:buy, :sell].include?(operation[:type])

      gain += operation[:value]
      gain_perc = deposit.zero? ? 0 : gain * 100 / deposit
      @gain_perc_history << { timestamp: operation[:timestamp], value: gain_perc }
    end

    @gain_perc_history
  end

  # This function return the gain percentage of the system at a given timestamp.
  def gain_perc_at(timestamp = Time.now)
    last_gain_perc = 0

    gain_perc_history.each do |gain_perc|
      break if gain_perc[:timestamp] > timestamp
      last_gain_perc = gain_perc[:value]
    end

    last_gain_perc
  end

  # This function returns the highest gain percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the highest gain percentage of the system.
  def highest_gain_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_gain_perc = nil

    gain_perc_history.each do |gain_perc|
      break if gain_perc[:timestamp] > end_time
      next if gain_perc[:timestamp] < start_time

      highest_gain_perc = gain_perc[:value] if highest_gain_perc.nil? || gain_perc[:value] > highest_gain_perc
    end

    highest_gain_perc
  end

  # This function returns the lowest gain percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest gain percentage of the system.
  def lowest_gain_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_gain_perc = nil

    gain_perc_history.each do |gain_perc|
      break if gain_perc[:timestamp] > end_time
      next if gain_perc[:timestamp] < start_time

      lowest_gain_perc = gain_perc[:value] if lowest_gain_perc.nil? || gain_perc[:value] < lowest_gain_perc
    end

    lowest_gain_perc
  end

  # This function returns the average gain percentage of the system between two timestamps.
  # If no timestamps are provided, it will return the average gain percentage of the system.
  def average_gain_perc_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_gain_perc = 0
    total_operations = 0

    gain_perc_history.each do |gain_perc|
      break if gain_perc[:timestamp] > end_time
      next if gain_perc[:timestamp] < start_time

      total_gain_perc += gain_perc[:value]
      total_operations += 1
    end

    total_gain_perc / total_operations
  end

  # GAIN METHODS
  ####################################################################################################################

  # This function returns the gain history of the system.
  # The gain is calculated by summing all the operations of type :buy and :sell.
  # The gain history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The gain of the system at that timestamp.
  def gain_history
    return @gain_history if defined? @gain_history

    @gain_history = []
    gain = 0

    @operations.each do |operation|
      next unless [:buy, :sell].include?(operation[:type])

      gain += operation[:value]
      @gain_history << { timestamp: operation[:timestamp], value: gain }
    end

    @gain_history
  end

  # This function return the gain of the system at a given timestamp.
  def gain_at(timestamp = Time.now)
    last_gain = 0

    gain_history.each do |gain|
      break if gain[:timestamp] > timestamp
      last_gain = gain[:value]
    end

    last_gain
  end

  # This function returns the highest gain of the system between two timestamps.
  # If no timestamps are provided, it will return the highest gain of the system.
  def highest_gain_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_gain = nil

    gain_history.each do |gain|
      break if gain[:timestamp] > end_time
      next if gain[:timestamp] < start_time

      highest_gain = gain[:value] if highest_gain.nil? || gain[:value] > highest_gain
    end

    highest_gain
  end

  # This function returns the lowest gain of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest gain of the system.
  def lowest_gain_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_gain = nil

    gain_history.each do |gain|
      break if gain[:timestamp] > end_time
      next if gain[:timestamp] < start_time

      lowest_gain = gain[:value] if lowest_gain.nil? || gain[:value] < lowest_gain
    end

    lowest_gain
  end

  # This function returns the average gain of the system between two timestamps.
  # If no timestamps are provided, it will return the average gain of the system.
  def average_gain_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_gain = 0
    total_operations = 0

    gain_history.each do |gain|
      break if gain[:timestamp] > end_time
      next if gain[:timestamp] < start_time

      total_gain += gain[:value]
      total_operations += 1
    end

    total_gain / total_operations
  end

  # BALANCE METHODS
  ####################################################################################################################

  # This function returns the balance history of the system.
  # The balance is calculated by summing all the operations.
  # The balance history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The balance of the system at that timestamp.
  def balance_history
    return @balance_history if defined? @balance_history

    @balance_history = []
    balance = 0

    @operations.each do |operation|
      balance += operation[:value]
      @balance_history << { timestamp: operation[:timestamp], value: balance }
    end

    @balance_history
  end

  # This function return the balance of the system at a given timestamp.
  def balance_at(timestamp = Time.now)
    last_balance = 0

    balance_history.each do |balance|
      break if balance[:timestamp] > timestamp
      last_balance = balance[:value]
    end

    last_balance
  end

  # This function returns the highest balance of the system between two timestamps.
  # If no timestamps are provided, it will return the highest balance of the system.
  def highest_balance_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_balance = nil

    balance_history.each do |balance|
      break if balance[:timestamp] > end_time
      next if balance[:timestamp] < start_time

      highest_balance = balance[:value] if highest_balance.nil? || balance[:value] > highest_balance
    end

    highest_balance
  end

  # This function returns the lowest balance of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest balance of the system.
  def lowest_balance_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_balance = nil

    balance_history.each do |balance|
      break if balance[:timestamp] > end_time
      next if balance[:timestamp] < start_time

      lowest_balance = balance[:value] if lowest_balance.nil? || balance[:value] < lowest_balance
    end

    lowest_balance
  end

  # This function returns the average balance of the system between two timestamps.
  # If no timestamps are provided, it will return the average balance of the system.
  def average_balance_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_balance = 0
    total_operations = 0

    balance_history.each do |balance|
      break if balance[:timestamp] > end_time
      next if balance[:timestamp] < start_time

      total_balance += balance[:value]
      total_operations += 1
    end

    total_balance / total_operations
  end

  # FILTERED OPERATIONS
  # These methods are used to filter the operations by type.
  # They are memoized to avoid recalculating them every time they are called.
  ####################################################################################################################

  def deposit_operations
    @deposit_operations ||= @operations.select { |operation| operation[:type] == :deposit }
  end

  def withdraw_operations
    @withdraw_operations ||= @operations.select { |operation| operation[:type] == :withdraw }
  end

  def buy_operations
    @buy_operations ||= @operations.select { |operation| operation[:type] == :buy }
  end

  def sell_operations
    @sell_operations ||= @operations.select { |operation| operation[:type] == :sell }
  end

  def win_operations
    @win_operations ||= @operations.select { |operation| operation[:value].positive? && [:buy, :sell].include?(operation[:type]) }
  end

  def loss_operations
    @loss_operations ||= @operations.select { |operation| operation[:value].negative? && [:buy, :sell].include?(operation[:type]) }
  end

  private

  # DEFAULT TIME RANGE
  # These methods are used to define the default time range for *_between methods.
  # They are used when the start_time or end_time are not provided.
  ####################################################################################################################

  def default_start_time
    @operations.first.dig(:timestamp) || Time.now
  end

  def default_end_time
    @operations.last.dig(:timestamp) || Time.now
  end

  # OTHER FUNCTIONS
  ####################################################################################################################

  # This method is used to validate and setup the operations before storing them.
  # Operations must be an array of hashes.
  def setup_operations(operations)
    # validate each operation using the validate_operation method
    operations.each do |operation|
      validate_operation(operation)
    end

    # return operations sorted by timestamp
    operations.sort_by { |operation| operation[:timestamp] }
  end

  # This method is used to validate an operation.
  # It raises an ArgumentError if the operation is not valid.
  # An operation is valid if it is a hash with the following keys:
  # - :type: The type of operation. It can be :buy, :sell, :deposit or :withdraw.
  # - :value: The value (profit) of the operation. It must be a float number.
  # - :timestamp: The timestamp of the operation. It must be a Time object.
  def validate_operation(operation)
    raise ArgumentError, "Invalid operation: #{operation}" unless operation.is_a?(Hash)
    raise ArgumentError, "Invalid operation type: #{operation[:type]}" unless [:buy, :sell, :deposit, :withdraw].include?(operation[:type])
    raise ArgumentError, "Invalid operation value: #{operation[:value]}" unless operation[:value].is_a?(Float)
    raise ArgumentError, "Invalid operation timestamp: #{operation[:timestamp]}" unless operation[:timestamp].is_a?(Time)

    # be sure that the value is positive for deposits and negative for withdraws
    if operation[:type] == :deposit
      raise ArgumentError, "Invalid deposit value: #{operation[:value]}" if operation[:value].negative?
    elsif operation[:type] == :withdraw
      raise ArgumentError, "Invalid withdraw value: #{operation[:value]}" if operation[:value].positive?
    end

    true
  end
end
