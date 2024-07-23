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

  def test_profit
    # Test profit_at
    # The profit at the beginning is 0
    assert_equal(0, tradealg.profit_at(before_first_timestamp))
    # After the first day, the profit is 0
    assert_equal(0, tradealg.profit_at(timestamp_at(1)))
    # After the second day, the profit is 0
    assert_equal(0, tradealg.profit_at(timestamp_at(2)))
    # After the third day, the profit is 0
    assert_equal(0, tradealg.profit_at(timestamp_at(3)))
    # After the fourth day, the profit is 10
    assert_equal(10, tradealg.profit_at(timestamp_at(4)))
    # After the fifth day, the profit is 20
    assert_equal(20, tradealg.profit_at(timestamp_at(5)))
    # After the sixth day, the profit is 10
    assert_equal(10, tradealg.profit_at(timestamp_at(6)))
    # After the seventh day, the profit is 0
    assert_equal(0, tradealg.profit_at(timestamp_at(7)))

    # Test highest_profit_between
    # The highest profit without timestamps is 20
    assert_equal(20, tradealg.highest_profit_between)
    # The highest profit between the first and the last day is 20
    assert_equal(20, tradealg.highest_profit_between(first_timestamp, last_timestamp))
    # The highest profit between the fifth and the sixth day is 20
    # PER_GIULIO: In questo caso è giusto 20 o dovrebbe essere 10? Nel caso in cui sia 10, forse ho sbagliato nomenclatura, ovvero questa cosa che sto calcolando non è il profitto ma il xxx?
    assert_equal(20, tradealg.highest_profit_between(timestamp_at(5), timestamp_at(6)))

    # Test average_profit_between
    # The average profit without timestamps is 10
    assert_equal(10, tradealg.average_profit_between)
    # PER_GIULIO: In linea con il dubbio sopra, è corretto che l'average sia 10? E' calcolato considerando:
    # - Giorno 1, 2, 3: non vengono considerati in quanto non ci sono operazioni di buy o sell
    # - Giorno 4: 10
    # - Giorno 5: 20
    # - Giorno 6: 10
    # - Giorno 7: 0
    # Quindi (10 + 20 + 10 + 0) / 4 = 10
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
