#                       #
# Funcion:FIX_outliers  #
#                       #
fix_outliers <- function(x, removeNA = TRUE){ #Calculamos los quantiles 1) por arriba del 5% y por debajo del 95%
  quantiles <- quantile(x, c(0.05, 0.95), na.rm = removeNA)
  x[x<quantiles[1]] <- mean(x, na.rm = removeNA)
  x[x>quantiles[2]] <- median(x, na.rm = removeNA)
  x
}
#                 #
#Variable:Adults  #
#                 #
boxplot(hotel$adults)
summary(hotel$adults)
hotel.adults_sin_out <- fix_outliers(hotel$adults)
hist(hotel.adults_sin_out)
boxplot.stats(hotel.adults_sin_out)

#                   #
#Variable: Children #
#                   #

summary(hotel$children)
hotel.children_sin_out <- fix_outliers(hotel$children)
hist(hotel.children_sin_out)
boxplot.stats(hotel.children_sin_out)

#                 #
#Variable: Babies #
#                 #

summary(hotel$babies)
hotel.babies_sin_out <- fix_outliers(hotel$babies)
hist(hotel.babies_sin_out)
boxplot.stats(hotel.babies_sin_out)
#               #
#Variable: adr  #
#               #

summary(hotel$adr)
hotel.adr_sin_out <- fix_outliers(hotel$adr)
hist(hotel.adr_sin_out)
boxplot.stats(hotel.adr_sin_out)
#                                       #
#Variable: required_car_parking_spaces  #
#                                       #

summary(hotel$required_car_parking_spaces)
hotel.required_car_parking_spaces_sin_out <- fix_outliers(hotel$required_car_parking_spaces)
hist(hotel.required_car_parking_spaces_sin_out)
boxplot.stats(hotel.required_car_parking_spaces_sin_out)

#                                       #
#Variable: total_of_special_requests    #
#                                       #

summary(hotel$total_of_special_requests)
hotel.total_of_special_requests_sin_out <- fix_outliers(hotel$total_of_special_requests)
hist(hotel.total_of_special_requests_sin_out)
boxplot.stats(hotel.total_of_special_requests_sin_out)

#                                 #
#Variable: days_in_waiting_list   #
#                                 #
 
summary(hotel$days_in_waiting_list)
hotel.days_in_waiting_list_sin_out <- fix_outliers(hotel$days_in_waiting_list)
hist(hotel.days_in_waiting_list_sin_out)
boxplot.stats(hotel.days_in_waiting_list_sin_out)

#                           #
#Variable: booking_changes  #
#                           #

summary(hotel$booking_changes)
hotel.booking_changes_sin_out <- fix_outliers(hotel$booking_changes)
hist(hotel.booking_changes_sin_out)
boxplot.stats(hotel.booking_changes_sin_out)

#                    #
#Variable: lead_time #
#                    #

summary(hotel$lead_time)
hotel.lead_time_sin_out <- fix_outliers(hotel$lead_time)
hist(hotel.lead_time_sin_out)
boxplot.stats(hotel.lead_time_sin_out)