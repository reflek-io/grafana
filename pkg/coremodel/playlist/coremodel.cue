package playlist

import (
	"github.com/grafana/thema"
)

thema.#Lineage
name: "playlist"
seqs: [
	{
		schemas: [
			{ //0.0
				// Serial database identifier of the playlist.
				id: int64
				// Unique playlist identifier. Generated on creation, either by the
				// creator of the playlist of by the application.
				uid: string
				// Name of the playlist.
				name: string
				// Interval sets the time between switching views in a playlist.
				// FIXME: Is this based on a standardized format or what options are available? Can datemath be used?
				interval: string | *"5m"
				// The ordered list of items that the playlist will iterate over.
				items?: [...#Item]

				///////////////////////////////////////
				// Definitions (referenced above) are declared below

				#Type: "dashboard_by_id" | "dashboard_by_tag" | "dashboard_by_uid" @cuetsy(kind="enum",memberNames="DashboardById|DashboardByTag|DashboardByUID")

				#Item: {
					// Type of the item.
					type: #Type
					// Value depends on type and describes the playlist item.
					//
					//  - dashboard_by_id: The value is an internal numerical identifier set by Grafana. This
					//  is not portable as the numerical identifier is non-deterministic between different instances. Deprecated.
					//  - dashboard_by_tag: The value is a tag which is set on any number of dashboards. All
					//  dashboards behind the tag will be added to the playlist.
					//  - dashboard_by_uid: The value is the UID identifier of a dashboard.
					value: string
					// Human-friendly title for item's listing in playlist.
					//
					// Deprecated.
					title: string
				}
			}
		]
	},
	{
		schemas: [
			{ //1.0
				// Unique playlist identifier. Generated on creation, either by the
				// creator of the playlist of by the application.
				uid: string
				// Name of the playlist.
				name: string
				// Interval sets the time between switching views in a playlist.
				// FIXME: Is this based on a standardized format or what options are available? Can datemath be used?
				interval: string | *"5m"
				// The ordered list of items that the playlist will iterate over.
				items?: [...#Item]

				///////////////////////////////////////
				// Definitions (referenced above) are declared below

				#Type: "dashboard_by_tag" | "dashboard_by_uid" @cuetsy(kind="enum",memberNames="DashboardByTag|DashboardByUID")

				#Item: {
					// Type of the item.
					type: #Type
					// Value depends on type and describes the playlist item.
					//
					//  - dashboard_by_tag: The value is a tag which is set on any number of dashboards. All
					//  dashboards behind the tag will be added to the playlist.
					//  - dashboard_by_uid: The value is the UID identifier of a dashboard.
					value: string
				}
			}
		]

        lens: forward: {
            to:         seqs[1].schemas[0]
            from:       seqs[0].schemas[0]
            translated: to & rel
            rel: {
            	uid: from.uid
            	name: from.name
            	interval: from.interval
            	items: [for item in from.items {
            		if (item.type == "dashboard_by_tag" || item.type == "dashboard_by_uid") {
            			item
            		}
            		if (item.type == "dashboard_by_id") {
            			type: "dashboard_by_uid"
            			value: "placeholder-cupcake-\(item.value)"
            		}
            	}]
            }
            lacunas: [
            	for i, item in from.items {
            		if (item.type == "dashboard_by_id") {
                        thema.#Lacuna & {
								sourceFields: [{
									path:  "items[\(i)]"
									value: item.value
								}]
								targetFields: [{
									path:  "items[\(i)]"
									value: "placeholder-cupcake-\(item.value)"
								}]
								message: "input was dashboard_by_id, converted to uid with universal dashboard uid placeholder prefix"
								type:    thema.#LacunaTypes.Placeholder
							}
                       }
            	}
            ]
        }
        lens: reverse: {
            to:         seqs[0].schemas[0]
            from:       seqs[1].schemas[0]
            translated: to & rel
            rel: {
            }
            lacunas: [
            ]
        }
	}
]
