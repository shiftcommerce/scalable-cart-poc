Boot up any of the apps in the subfolders with

```bash
foreman start
```

Run the load test with:

```bash
bzt taurus.yml
```

Current results:

```
### redis-only-cart ###
Test duration: 0:01:36
Samples count: 126792, 0.00% failures (1321/s)
Average times: total 0.059, latency 0.059, connect 0.000
Percentile 0.0%: 0.001
Percentile 50.0%: 0.054
Percentile 90.0%: 0.118
Percentile 95.0%: 0.133
Percentile 99.0%: 0.165
Percentile 99.9%: 0.221
Percentile 100.0%: 0.358

### cookie-only-cart ###
Test duration: 0:01:34
Samples count: 155192, 0.00% failures (1651/s, +25%)
Average times: total 0.048, latency 0.048, connect 0.000
Percentile 0.0%: 0.000
Percentile 50.0%: 0.049
Percentile 90.0%: 0.100
Percentile 95.0%: 0.122
Percentile 99.0%: 0.177
Percentile 99.9%: 0.240
Percentile 100.0%: 0.336
```
