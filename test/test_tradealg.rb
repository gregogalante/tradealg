require "minitest/autorun"
require "tradealg"

OPERATIONS = [
  { type: :deposit, value: 100.0, timestamp: Time.new(2000, 1, 1, 0, 0, 0) }, # giorno 1
  { type: :deposit, value: 50.0, timestamp: Time.new(2000, 1, 2, 0, 0, 0) }, # giorno 2
  { type: :deposit, value: 25.0, timestamp: Time.new(2000, 1, 3, 0, 0, 0) }, # giorno 3
  { type: :buy, value: 10.0, timestamp: Time.new(2000, 1, 4, 0, 0, 0) }, # giorno 4
  { type: :sell, value: 10.0, timestamp: Time.new(2000, 1, 5, 0, 0, 0) }, # giorno 5
  { type: :buy, value: -10.0, timestamp: Time.new(2000, 1, 6, 0, 0, 0) }, # giorno 6
  { type: :sell, value: -10.0, timestamp: Time.new(2000, 1, 7, 0, 0, 0) }, # giorno 7
]

class TradealgTest < Minitest::Test
  def test_initialize_without_operations
    tradealg = Tradealg.new([])
    assert_equal([], tradealg.operations)
  end

  # DRAWDOWN METHODS
  ####################################################################################################################

  def test_drawdown
    # Test drawdown_at
    # The drawdown at the beginning is 0
    assert_equal(0, tradealg.drawdown_at(before_first_timestamp))
    # After the first day, the drawdown is 0
    assert_equal(0, tradealg.drawdown_at(timestamp_at(1)))
    # After the second day, the drawdown is 0
    assert_equal(0, tradealg.drawdown_at(timestamp_at(2)))
    # After the third day, the drawdown is 0
    assert_equal(0, tradealg.drawdown_at(timestamp_at(3)))
    # After the fourth day, the drawdown is 0
    assert_equal(0, tradealg.drawdown_at(timestamp_at(4)))
    # After the fifth day, the drawdown is 0
    assert_equal(0, tradealg.drawdown_at(timestamp_at(5)))
    # After the sixth day, the drawdown is 10
    assert_equal(10, tradealg.drawdown_at(timestamp_at(6)))
    # After the seventh day, the drawdown is 20
    assert_equal(20, tradealg.drawdown_at(timestamp_at(7)))

    # Test highest_drawdown_between
    # The highest drawdown without timestamps is 20
    assert_equal(20, tradealg.highest_drawdown_between)
    # The highest drawdown between the first and the last day is 20
    assert_equal(20, tradealg.highest_drawdown_between(first_timestamp, last_timestamp))
    # The highest drawdown between the sixth and the seventh day is 20
    assert_equal(20, tradealg.highest_drawdown_between(timestamp_at(6), timestamp_at(7)))

    # Test average_drawdown_between
    # The average drawdown without timestamp is 4.29
    assert_equal(4.29, tradealg.average_drawdown_between.round(2))
  end

  # GAIN PERC METHODS
  ####################################################################################################################

  def test_gain_perc
    # Test gain_perc_at
    # The gain percentage at the beginning is 0
    assert_equal(0, tradealg.gain_perc_at(before_first_timestamp))
    # After the first day, the gain is 0
    assert_equal(0, tradealg.gain_perc_at(timestamp_at(1)))
    # After the second day, the gain is 0
    assert_equal(0, tradealg.gain_perc_at(timestamp_at(2)))
    # After the third day, the gain is 0
    assert_equal(0, tradealg.gain_perc_at(timestamp_at(3)))
    # After the fourth day, the gain is 10 * 100 / 175
    assert_equal(10 * 100.0 / 175, tradealg.gain_perc_at(timestamp_at(4)))
    # After the fifth day, the gain is 20 * 100 / 175
    assert_equal(20 * 100.0 / 175, tradealg.gain_perc_at(timestamp_at(5)))
    # After the sixth day, the gain is 10 * 100 / 175
    assert_equal(10 * 100.0 / 175, tradealg.gain_perc_at(timestamp_at(6)))
    # After the seventh day, the gain is 0
    assert_equal(0, tradealg.gain_perc_at(timestamp_at(7)))

    # Test highest_gain_perc_between
    # The highest gain percentage without timestamps is 20 * 100 / 175
    assert_equal(20 * 100.0 / 175, tradealg.highest_gain_perc_between)
    # The highest gain percentage between the first and the last day is 20 * 100 / 175
    assert_equal(20 * 100.0 / 175, tradealg.highest_gain_perc_between(first_timestamp, last_timestamp))
    # The highest gain percentage between the fifth and the sixth day is 20 * 100 / 175
    assert_equal(20 * 100.0 / 175, tradealg.highest_gain_perc_between(timestamp_at(5), timestamp_at(6)))

    # Test average_gain_perc_between
    # The average gain percentage without timestamps is 10 * 100 / 175
    assert_equal(10 * 100.0 / 175, tradealg.average_gain_perc_between)
  end

  # GAIN METHODS
  ####################################################################################################################

  def test_gain
    # Test gain_at
    # The gain at the beginning is 0
    assert_equal(0, tradealg.gain_at(before_first_timestamp))
    # After the first day, the gain is 0
    assert_equal(0, tradealg.gain_at(timestamp_at(1)))
    # After the second day, the gain is 0
    assert_equal(0, tradealg.gain_at(timestamp_at(2)))
    # After the third day, the gain is 0
    assert_equal(0, tradealg.gain_at(timestamp_at(3)))
    # After the fourth day, the gain is 10
    assert_equal(10, tradealg.gain_at(timestamp_at(4)))
    # After the fifth day, the gain is 20
    assert_equal(20, tradealg.gain_at(timestamp_at(5)))
    # After the sixth day, the gain is 10
    assert_equal(10, tradealg.gain_at(timestamp_at(6)))
    # After the seventh day, the gain is 0
    assert_equal(0, tradealg.gain_at(timestamp_at(7)))

    # Test highest_gain_between
    # The highest gain without timestamps is 20
    assert_equal(20, tradealg.highest_gain_between)
    # The highest gain between the first and the last day is 20
    assert_equal(20, tradealg.highest_gain_between(first_timestamp, last_timestamp))
    # The highest gain between the fifth and the sixth day is 20
    assert_equal(20, tradealg.highest_gain_between(timestamp_at(5), timestamp_at(6)))

    # Test average_gain_between
    # The average gain without timestamps is 10
    assert_equal(10, tradealg.average_gain_between)
  end

  # BALANCE METHODS
  ####################################################################################################################

  def test_balance
    # Test balance_at
    # The balance at the beginning is 0
    assert_equal(0, tradealg.balance_at(before_first_timestamp))
    # After the first day, the balance is 100
    assert_equal(100, tradealg.balance_at(timestamp_at(1)))
    # After the second day, the balance is 150
    assert_equal(150, tradealg.balance_at(timestamp_at(2)))
    # After the third day, the balance is 175
    assert_equal(175, tradealg.balance_at(timestamp_at(3)))
    # After the fourth day, the balance is 185
    assert_equal(185, tradealg.balance_at(timestamp_at(4)))
    # After the fifth day, the balance is 195
    assert_equal(195, tradealg.balance_at(timestamp_at(5)))
    # After the sixth day, the balance is 185
    assert_equal(185, tradealg.balance_at(timestamp_at(6)))
    # After the seventh day, the balance is 175
    assert_equal(175, tradealg.balance_at(timestamp_at(7)))

    # Test highest_balance_between
    # The highest balance without timestamps is 195
    assert_equal(195, tradealg.highest_balance_between)
    # The highest balance between the first and the last day is 195
    assert_equal(195, tradealg.highest_balance_between(first_timestamp, last_timestamp))
    # The highest balance between the sixth and the seventh day is 185
    assert_equal(185, tradealg.highest_balance_between(timestamp_at(6), timestamp_at(7)))

    # Test lowest_balance_between
    # The lowest balance without timestamps is 100
    assert_equal(100, tradealg.lowest_balance_between)
    # The lowest balance between the first and the last day is 100
    assert_equal(100, tradealg.lowest_balance_between(first_timestamp, last_timestamp))
    # The lowest balance between the sixth and the seventh day is 175
    assert_equal(175, tradealg.lowest_balance_between(timestamp_at(6), timestamp_at(7)))
  end

  private

  def tradealg
    @tradealg ||= Tradealg.new(OPERATIONS)
  end

  def before_first_timestamp
    OPERATIONS.first[:timestamp] - 1
  end

  def first_timestamp
    OPERATIONS.first[:timestamp]
  end

  def last_timestamp
    OPERATIONS.last[:timestamp]
  end

  def timestamp_at(day)
    Time.new(2000, 1, day, 0, 0, 0)
  end
end
