class Tradealg
  attr_reader :operations

  def initialize(operations)
    @operations = setup_operations(operations)
  end

  # ----------------------------------------------------
  # EQUITY   _history (history of monetary equity/balance) ✅ balance_history
  # EQUITY_MIN ✅ lowest_balance_between
  # EQUITY_MAX ✅ highest_balance_between
  # GAIN_MONETARY   _history (history of monetary gain/P&L) ✅ gain_history
  # GAIN_PERCENT   _history (history of percent gain/P&L relativo ad EQUITY iniziale assoluta)
  # GAIN_ABSOLUTE (gain inteso come gain percentuale sul totale dei depositi: i nuovi depositi influenzano l'absolute gain)
  # TOTAL PROFIT = GAIN_MONETARY _between all available history (not selected history)
  # DRAWDOWN_MONETARY   _history (history of monetary drawdown)
  # DRAWDOWN_PERCENT   _history (history of percent drawdown relativo ad EQUITY iniziale assoluta)
  # MAX_DRAWDOWN_MONETARY
  # MAX_DRAWDOWN_PERCENT
  # AVG_DRAWDOWN_MONETARY
  # AVG_DRAWDOWN_PERCENT
  # CONSISTENCY
  # EXPECTANCY
  # PROFIT FACTOR
  # WIN RATE
  # WIN RATE LONG
  # WIN RATE SHORT
  # RISK REWARD
  # BEST TRADE
  # WORST TRADE
  # AVERAGE WIN
  # AVERAGE LOSS
  # MONTHLY PROFIT
  # MONTHLY DRAWDOWN STANDARD DEVIATION
  # SORTINO RATIO
  # MAX DRAWDOWN FROM LAST MONDAY
  # MAX DRAWDOWN FROM SECOND LAST MONDAY
  # MAX DRAWDOWN FROM THIRD LAST MONDAY
  # ACTUAL DRAWDOWN FROM LAST MONDAY
  # ACTUAL DRAWDOWN FROM SECOND LAST MONDAY
  # ACTUAL DRAWDOWN FROM THIRD LAST MONDAY
  # ----------------------------------------------------

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
