{
    "book_id": {{random.number(
        {
            "min":1,
            "max":10
        })}},
    "trader_id": {{random.number(
        {
            "min":1,
            "max":20
        })}},
    "instrument_id": {{random.number(
        {
            "min":1,
            "max":50
        })}},
    "qty": {{random.number(
        {
            "min":1000,
            "max":5000
        })}},
    "price": {{random.number(
        {
            "min":1,
            "max":15
        })}},
    "ts": "{{date.now}}"
}