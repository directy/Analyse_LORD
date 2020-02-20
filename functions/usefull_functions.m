

velocity=cumtrapz(time,acceleration)


velocity=cumtrapz(tsc.Time,tsc.scaledAccelX.Data);
ts_help = timeseries(velocity,tsc.Time,'Name',velocity);
