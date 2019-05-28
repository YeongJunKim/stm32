/*
 * AuCAR.h
 *
 *  Created on: May 28, 2019
 *      Author: colson
 *      email: dud3722000@naver.com
 *      email: colson@korea.ac.kr
 *      YeongJunKim
 */

#ifndef _ROS_aucar_msgs_AuCAR_h
#define _ROS_aucar_msgs_AuCAR_h

#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "ros/msg.h"
#include "std_msgs/Header.h"
#include "ros/time.h"

namespace aucar_msgs
{
	class AuCAR : public ros::Msg
	{
	public:
		typedef std_msgs::Header _header_type;
		_header_type header;
		typedef ros::Time _time_ref_type;
		_time_ref_type time_ref;
		typedef const char* _source_type;
		_source_type source;

		AuCAR():
			header(),
			time_ref(),
			source("")
		{

		}
	};
}


#endif /* AUCAR_H_ */
