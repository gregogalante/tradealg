class Tradealg
  attr_reader :operations

  def initialize(operations)
    @operations = setup_operations(operations)
  end

  # PER_GIULIO: riesci a mettermi qui la lista di tutti i dati che dovrebbero servirci?
  # ----------------------------------------------------
  # EQUITY   _history (history of monetary equity/balance)
  # EQUITY_MIN
  # EQUITY_MAX
  # GAIN_MONETARY   _history (history of monetary gain/P&L)
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

  # In generale, per ogni dato, io manterrei una struttura in cui abbiamo sempre:
  # - un metodo *_history che restituisce un array con lo storico del valore ad ogni timestamp
  # - un metodo *_at che restituisce il valore al timestamp specificato
  # - nel caso di highest, lowest, average, etc, un metodo *_between che restituisce il valore tra due timestamp

  # PROFIT METHODS
  ##

  # This function returns the profit history of the system.
  # The profit is calculated by summing all the operations of type :buy and :sell.
  # The profit history is an array of hashes with the following keys:
  # - :timestamp: The timestamp of the operation.
  # - :value: The profit of the system at that timestamp.
  def profit_history
    return @profit_history if defined? @profit_history

    @profit_history = []
    profit = 0

    @operations.each do |operation|
      next unless [:buy, :sell].include?(operation[:type])

      profit += operation[:value]
      @profit_history << { timestamp: operation[:timestamp], value: profit }
    end

    @profit_history
  end

  # This function return the profit of the system at a given timestamp.
  def profit_at(timestamp = Time.now)
    last_profit = 0

    profit_history.each do |profit|
      break if profit[:timestamp] > timestamp
      last_profit = profit[:value]
    end

    last_profit
  end

  # This function returns the highest profit of the system between two timestamps.
  # If no timestamps are provided, it will return the highest profit of the system.
  def highest_profit_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    highest_profit = nil

    profit_history.each do |profit|
      break if profit[:timestamp] > end_time
      next if profit[:timestamp] < start_time

      highest_profit = profit[:value] if highest_profit.nil? || profit[:value] > highest_profit
    end

    highest_profit
  end

  # This function returns the lowest profit of the system between two timestamps.
  # If no timestamps are provided, it will return the lowest profit of the system.
  def lowest_profit_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    lowest_profit = nil

    profit_history.each do |profit|
      break if profit[:timestamp] > end_time
      next if profit[:timestamp] < start_time

      lowest_profit = profit[:value] if lowest_profit.nil? || profit[:value] < lowest_profit
    end

    lowest_profit
  end

  # This function returns the average profit of the system between two timestamps.
  # If no timestamps are provided, it will return the average profit of the system.
  def average_profit_between(start_time = nil, end_time = nil)
    start_time ||= default_start_time
    end_time ||= default_end_time

    total_profit = 0
    total_operations = 0

    profit_history.each do |profit|
      break if profit[:timestamp] > end_time
      next if profit[:timestamp] < start_time

      total_profit += profit[:value]
      total_operations += 1
    end

    total_profit / total_operations
  end

  # BALANCE METHODS
  ##

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
  ##

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

  def default_start_time
    @operations.first.dig(:timestamp) || Time.now
  end

  def default_end_time
    @operations.last.dig(:timestamp) || Time.now
  end

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
