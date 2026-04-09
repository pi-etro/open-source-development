---
layout: post
title:  "↔️ Introduction to the Industrial I/O (IIO) subsystem"
date:   2026-04-01 16:20:00 -0300
categories: [linux kernel]
---

### tl;dr

- Enable the IIO dummy module via nconfig;
- Compile the IIO dummy module;
- Load and unload iio_dummy module;
- Inspect the /sys/bus/iio/*;
- Modify iio_simple_dummy module to add channels for a 3-axis compass.

### Commands

```bash
# Load iio_dummy
sudo modprobe iio_dummy

# Get iio_dummy info
modinfo iio_dummy
lsmod | grep iio_dummy
ls -l /sys/bus/iio/devices
ls -l /sys/bus/iio/devices/iio:device0/

# About configfs in the iio_dummy
sudo mkdir /mnt/iio_experiments/
sudo mount -t configfs none /mnt/iio_experiments/
ls /mnt/iio_experiments/
ls /mnt/iio_experiments/iio/devices/
sudo mkdir /mnt/iio_experiments/iio/devices/dummy/my_glorious_dummy_device
```

### Notes

An IIO device **channel** is a representation of a data channel, and a single IIO device may have one or more channels.

In this tutorial we created channels for a 3-axis Compass. For this we started altering the file 
`lk_dev/iio/drivers/iio/dummy/iio_simple_dummy.h`.

```diff
#ifndef _IIO_SIMPLE_DUMMY_H_
#define _IIO_SIMPLE_DUMMY_H_
#include <linux/kernel.h>

struct iio_dummy_accel_calibscale;
struct iio_dummy_regs;

+ #define DUMMY_AXIS_XYZ 3

...

struct iio_dummy_state {
	int dac_val;
	int single_ended_adc_val;
	int differential_adc_val[2];
	int accel_val;
	int accel_calibbias;
	int activity_running;
	int activity_walking;
	const struct iio_dummy_accel_calibscale *accel_calibscale;
	struct mutex lock;
	struct iio_dummy_regs *regs;
	int steps_enabled;
	int steps;
	int height;
+	u16 buffer_compass[DUMMY_AXIS_XYZ];
#ifdef CONFIG_IIO_SIMPLE_DUMMY_EVENTS
	int event_irq;
	int event_val;
	bool event_en;
	s64 event_timestamp;
#endif /* CONFIG_IIO_SIMPLE_DUMMY_EVENTS */
};

...

enum iio_simple_dummy_scan_elements {
	DUMMY_INDEX_VOLTAGE_0,
	DUMMY_INDEX_DIFFVOLTAGE_1M2,
	DUMMY_INDEX_DIFFVOLTAGE_3M4,
	DUMMY_INDEX_ACCELX,
+	DUMMY_INDEX_SOFT_TIMESTAMP,
+	DUMMY_MAGN_X,
+	DUMMY_MAGN_Y,
+	DUMMY_MAGN_Z,
};
```

Then we changed the file `lk_dev/iio/drivers/iio/dummy/iio_simple_dummy.c`:

```diff
...

static const struct iio_chan_spec iio_dummy_channels[] = {
    ...
-	IIO_CHAN_SOFT_TIMESTAMP(4),
+	IIO_CHAN_SOFT_TIMESTAMP(DUMMY_INDEX_SOFT_TIMESTAMP),
    ...
+ 	{
+ 		.type = IIO_MAGN,
+ 		.modified = 1,
+ 		.channel2 = IIO_MOD_X,
+ 		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
+ 		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_SCALE),
+ 		.scan_index = DUMMY_MAGN_X,
+ 		.scan_type = {
+ 			.sign = 'u',
+ 			.realbits = 16,
+ 			.storagebits = 16,
+ 			.shift = 0,
+ 		},
+ 	},
+ 	{
+ 		.type = IIO_MAGN,
+ 		.modified = 1,
+ 		.channel2 = IIO_MOD_Y,
+ 		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
+ 		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_SCALE),
+ 		.scan_index = DUMMY_MAGN_Y,
+ 		.scan_type = {
+ 			.sign = 'u',
+ 			.realbits = 16,
+ 			.storagebits = 16,
+ 			.shift = 0,
+ 		},
+ 	},
+ 	{
+ 		.type = IIO_MAGN,
+ 		.modified = 1,
+ 		.channel2 = IIO_MOD_Z,
+ 		.info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
+ 		.info_mask_shared_by_type = BIT(IIO_CHAN_INFO_SCALE),
+ 		.scan_index = DUMMY_MAGN_Z,
+ 		.scan_type = {
+ 			.sign = 'u',
+ 			.realbits = 16,
+ 			.storagebits = 16,
+ 			.shift = 0,
+ 		},
+ 	},
};

...

static int __iio_dummy_read_raw(struct iio_dev *indio_dev,
				struct iio_chan_spec const *chan,
				int *val)
{
    ...
    	case IIO_ACCEL:
		*val = st->accel_val;
		return IIO_VAL_INT;
+	case IIO_MAGN:
+		switch(chan->scan_index) {
+		case DUMMY_MAGN_X:
+			*val = st->buffer_compass[0];
+			break;
+		case DUMMY_MAGN_Y:
+			*val = st->buffer_compass[1];
+			break;
+		case DUMMY_MAGN_Z:
+			*val = st->buffer_compass[2];
+			break;
+		default:
+			*val = 99;
+			break;
+		}
+		return IIO_VAL_INT;
	default:
		return -EINVAL;
	}
}

...

static int iio_dummy_read_raw(struct iio_dev *indio_dev,
			      struct iio_chan_spec const *chan,
			      int *val,
			      int *val2,
			      long mask)
{
	struct iio_dummy_state *st = iio_priv(indio_dev);
	int ret;

	switch (mask) {
	...
	case IIO_CHAN_INFO_SCALE:
		switch (chan->type) {
		case IIO_VOLTAGE:
			...
+		case IIO_MAGN:
+			// Just add some dummy values
+			*val = 0;
+			*val2 = 2;
+			return IIO_VAL_INT_PLUS_MICRO;
        ...
        }
    ...
    }
}

...

static int iio_dummy_init_device(struct iio_dev *indio_dev)
{
	...
+	st->buffer_compass[0] = 78;
+	st->buffer_compass[1] = 10;
+	st->buffer_compass[2] = 3;

	return 0;
}

...

MODULE_AUTHOR("Jonathan Cameron <jic23@kernel.org>");
+MODULE_DESCRIPTION("IIO dummy driver -> IIO dummy modified by Me");
MODULE_LICENSE("GPL v2");
```

Comparing code changes suggested in the tutorial, I had to make some adjustments. First, it wasn't clear that we needed
to add the others channels to the `iio_chan_spec iio_dummy_channels` struct by copying the previous one and
changing the `.channel2` and `.scan_index` values.

The other adjustment was `case IIO_MAGN` both on `__iio_dummy_read_raw()` and `iio_dummy_read_raw()` instead of setting
the value of `ret` and breaking from the switch, I had to return the value of `ret` (`IIO_VAL_INT` and `IIO_VAL_INT_PLUS_MICRO` respectively).

Another detail was that the code was updated and now `IIO_CHAN_INFO_RAW` calls `__iio_dummy_read_raw()`, that's why we had to
add the `case IIO_MAGN` to this new function instead of adding it directly under `IIO_CHAN_INFO_RAW`.

After this I successfully got the values of each new attribute: `in_magn_x_raw`, `in_magn_y_raw`, `in_magn_z_raw`, and `in_magn_scale`.

### Reference

[The iio_simple_dummy Anatomy](https://flusp.imiio_dummye.usp.br/iio/iio-dummy-anatomy/)

[IIO Dummy module Experiment One: Play with iio_dummy](https://flusp.ime.usp.br/iio/experiment-one-iio-dummy/)
