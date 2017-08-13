from uber_rides.session import Session
from uber_rides.client import UberRidesClient
from influxdb import InfluxDBClient
import params
import schedule
import time

uberSession = Session(params.server_token)
uberClient = UberRidesClient(uberSession)
influxClient = InfluxDBClient(params.influxHost, 8086, params.influxUser, params.influxPass, 'uber')

def job():
	start = {
		'lat' : params.start_latitude,
		'lon' : params.start_longitude,
		'name' : params.start_name
	}
	end = {
		'lat' : params.end_latitude,
		'lon' : params.end_longitude,
		'name' : params.end_name
	}
	try:
		estimate = getFares(start,end)
		sendFaresToInflux(estimate, start, end)

		estimate = getFares(end,start)
		sendFaresToInflux(estimate, end, start)
	except Exception:
		pass
		
	return

def getFares(start, end):
	response = uberClient.get_price_estimates(
	    start_latitude=start['lat'],
	    start_longitude=start['lon'],
	    end_latitude=end['lat'],
	    end_longitude=end['lon']
	)
	estimate = response.json.get('prices')

	return estimate

def sendFaresToInflux(estimate, start, end):
	global influxClient
	now = int(time.time()*1000000000)
	for fare in estimate:
		json_body = [
		    {
		        "measurement": "uber fares",
		        "tags": {
		            "start": start['name'],
		            "end": end['name'],
		            "vehicle":fare['display_name']
		        },
		        "time": now,
		        "fields": {
		            "fare": float((fare['high_estimate']+fare['low_estimate'])/2),
		            "high_estimate": fare['high_estimate'],
		            "low_estimate": fare['low_estimate'],
		            "duration": fare['duration'],
		            "distance": fare['distance'],
		            "surge_multiplier":fare['surge_multiplier']
		        }
		    }
		]
		influxClient.write_points(json_body)

	return

schedule.every(10).seconds.do(job)

while True:
    schedule.run_pending()
    time.sleep(1)