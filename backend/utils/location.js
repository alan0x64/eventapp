const RADIUS_OF_EARTH = 6371

function parseLatLon(latLonString) {
  const [lat, lon] = latLonString.split(',')
  return [parseFloat(lat), parseFloat(lon)]
}

function calculateDis(lat1, lon1, lat2, lon2) {
  const dLat = (Math.PI / 180) * (lat2 - lat1)
  const dLon = (Math.PI / 180) * (lon2 - lon1)


  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos((Math.PI / 180) * lat1) * Math.cos((Math.PI / 180) * lat2) * Math.sin(dLon / 2) * Math.sin(dLon / 2)
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

  return RADIUS_OF_EARTH * c
}


function isInsideCircle(req, eventLocation) {
  let userLat = req.query.lat
  let userLon = req.query.lon
  let eventLat = parseLatLon(eventLocation)[0]
  let eventLon = parseLatLon(eventLocation)[1]
  let radius = req.query.radius || 10

  // const dis = calculateDis(eventLat, eventLon, userLat, userLon)
  const dis = calculateDis( userLat, userLon,eventLat, eventLon)

  return dis <= radius
}



module.exports = {
  isInsideCircle,
  parseLatLon,
}