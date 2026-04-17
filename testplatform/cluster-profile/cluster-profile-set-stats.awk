$0 ~ clusterprofile {
    split($1, profile, "--"); 
    profiles[profile[1]] = ""
    i = profile[1] "_" $3
    stats[i] = stats[i] + 1
}

END {
    print "PROFILE FREE LEASED"
    for (p in profiles) print p " " stats[p"_free"] " " stats[p"_leased"]
}
