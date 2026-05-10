sketchybar --set $NAME \
  label="Loading..." \
  icon.color=0xff5edaff

# Fetch weather data
LOCATION="Al Kharj"
REGION="Saudi Arabia"
LANG="en"  # Language set to English

# Escape location for URL (replace spaces with +)
LOCATION_ESCAPED="${LOCATION// /+}+${REGION// /+}"
WEATHER_JSON=$(curl -s "https://wttr.in/$LOCATION_ESCAPED?0pq&format=j1&lang=$LANG")

# Fallback if empty
if [ -z "$WEATHER_JSON" ]; then
  sketchybar --set $NAME label="$LOCATION"
  exit 0
fi

# Extract temperature and weather description
TEMPERATURE=$(echo "$WEATHER_JSON" | jq '.current_condition[0].temp_C' | tr -d '"')
WEATHER_DESCRIPTION=$(echo "$WEATHER_JSON" | jq '.current_condition[0].weatherDesc[0].value' | tr -d '"' | sed 's/\(.\{16\}\).*/\1.../')

# Update SketchyBar with weather data
sketchybar --set $NAME \
  label="$TEMPERATURE$(echo '°')C • $WEATHER_DESCRIPTION"
