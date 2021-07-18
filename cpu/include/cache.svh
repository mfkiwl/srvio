/*
* <cache.svh>
*
* Copyright (c) 2021 Yosuke Ide <yosuke.ide@keio.jp>
*
* This software is released under the MIT License.
* https://opensource.org/licenses/mit-license.php
*/

`ifndef _CACHE_SVH_INCLUDED_
`define _CACHE_SVH_INCLUDED_

// <asciidoc>
// = cache.svh
// Configurations and utilities for caches
// </asciidoc>

`include "cpu_config.svh"

//***** Cache type
// <asciidoc>
// [[Cache-Type]]
// == CacheType_t (Enumenration for cache type)
// PHYS:: Physical Cache
// PIPT:: Physically Indexed Physically Tagged (Virtual Cache)
// VIPT:: Virtually Indexed Physically Tagged (Virtual Cache)
// </asciidoc>
`define CacheTypeWidth	2
`define CacheType		`CacheTypeWidth-1:0
typedef enum logic [`CacheType] {
	PHYS	= 'b00,
	PIPT	= 'b01,
	VIPT	= 'b10
} CacheType_t;



//***** Cache Configuration Struct
// <asciidoc>
// [[Cache-Configuration]]
// == CacheConfig_t (Struct for cache configuration)
// cache:: cache type (<<Cache-Type>,<CacheType_t>>)
// depth:: depth of cache ram
// way:: number of ways in the cache
// bank:: number of cache ram banks in the cache
// delay:: cache access latency
// </asciidoc>
typedef struct packed {
	CacheType_t		cache;
	int				line;		// cache line size
	int				depth;		// cache depth
	int				way;		// cache way
	int				bank;		// cache bank
	int				delay;
} CacheConfig_t;

//*** default config (returns CacheConfig_t)
`define IC_Conf		CacheConfig::get_param( \
						"K",				\
						`VirtualCache,		\
						`L1_ICacheSize,		\
						`L1_ICacheLine,		\
						`L1_ICacheWay,		\
						`L1_DCacheBank,		\
						`L1_ICacheVIPT		\
					)

`define	DC_Conf		CacheConfig:;get_param( \
						"K",				\
						`VirtualCache,		\
						`L1_DCacheSize,		\
						`L1_DCacheLine,		\
						`L1_DCacheWay,		\
						`L1_DCacheBank,		\
						`L1_ICacheVIPT		\
					)



//***** Acquire configuration parameters
// <asciidoc>
// [[Cache-Config-Class]]
// == CacheConfig (Cache configuration automation class)
// get_param:: return cache configuration parameter 
//		(<<Cache-Configuration>,<CacheConfig_t>>) 
// get_depth:: return cache ram depth
// </asciidoc>
virtual class CacheConfig;
	static function CacheConfig_t get_param (
		input string		unit,		// Unit size (K: KiB, M: MiB)
		input CacheType_t	cache,		// cache type
		input int			size,		// cache size (in KiB)
		input int			line,		// cache line width
		input int			way,		// cache ways
		input int			bank		// cache banks
	);

		int					delay;
		int					depth;

		//*** calculate cache depth
		depth = get_depth(unit, size, way, bank, line);

		//*** access latency
		case ( cache )
			PHYS : begin
				delay = 1;
			end
			PIPT : begin
				delay = 3;
			end
			VIPT : begin
				delay = 2;
			end
			default : begin
				delay = 0;
			end
		endcase

		get_param = CacheConfig_t'{
			cache	: cache,
			line	: line,
			depth	: depth,
			way		: way,
			bank	: bank,
			delay	: delay
		};
	endfunction

	//*** calculate depth of a cache
	static function int get_depth (
		input string	unit,	// unit size (KiB or MiB)
		input int		size,	// cache capacity (size * unit Byte)
		input int		way,	// # of cache way
		input int		bank,	// # of cache bank
		input int		line	// cache line width
	);
		int				size_in_byte;
		int				line_in_byte;

		case ( unit )
			"K" : begin
				size_in_byte = size * `Kilo;
			end
			"M" : begin
				size_in_byte = size * `Mega;
			end
			default : begin
				size_in_byte = 0;
				$error("Error: \"%s\" is invalid for cache unit size", unit);
			end
		endcase

		line_in_byte = line / `ByteBitWidth;

		get_depth = size_in_byte / (line_in_byte * way * bank);
	endfunction

endclass


`endif // _CACHE_SVH_INCLUDED_
