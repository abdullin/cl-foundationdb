;;; -*- Mode: Lisp -*-

(in-package :foundationdb)

(define-foreign-library libfdb
  (t (:default "libfdb_c")))

(use-foreign-library libfdb)

(defctype fdb-future :pointer)
(defctype fdb-cluster :pointer)
(defctype fdb-database :pointer)
(defctype fdb-transaction :pointer)

(defctype fdb-error-t :int)
(defctype fdb-bool-t :boolean)

(defcenum fdb-network-option
  (:local-address 10)
  (:cluster-file 20)
  (:trace-enable 30))

(defcenum fdb-cluster-option)

(defcenum fdb-database-option
  (:location-cache-size 10)
  (:max-watches 20)
  (:machine-id 21)
  (:datacenter-id 22))

(defcenum fdb-transaction-option
  (:causal-write-risky 10)
  (:causal-read-risky 20)
  (:causal-read-disable 21)
  (:next-write-no-write-conflict-range 30)
  (:check-writes-enable 50)
  (:read-your-writes-disable 51)
  (:read-ahead-disable 52)
  (:durability-datacenter 110)
  (:durability-risky 120)
  (:durability-dev-null-is-web-scale 130)
  (:priority-system-immediate 200)
  (:priority-batch 201)
  (:initialize-new-database 300)
  (:access-system-keys 301)
  (:debug-dump 400)
  (:timeout 500)
  (:retry-limit 501))

(defcenum fdb-streaming-mode
  (:want-all -2)
  (:iterator -1)
  (:exact 0)
  (:small 1)
  (:medium 2)
  (:large 3)
  (:serial 4))

(defcenum fdb-mutation-type
  (:add 2)
  (:and 6)
  (:or 7)
  (:xor 8))

(defcenum fdb-conflict-range-type
  (:read 0)
  (:write 1))

(defcfun "fdb_get_error" :string
    (code fdb-error-t))

(defcfun "fdb_network_set_option" fdb-error-t
  (option fdb-network-option)
  (value (:pointer :uint8))
  (value-length :int))

(defcfun "fdb_setup_network" fdb-error-t)

(defcfun "fdb_run_network" fdb-error-t)

(defcfun "fdb_stop_network" fdb-error-t)

(defcstruct (fdb-key-value :size 24)    ; No way of saying alignment / pack is 4.
  (key :pointer :offset 0)
  (key-length :int :offset 8)
  (value :pointer :offset 12)
  (value-length :int :offset 20))

(defcfun "fdb_future_cancel" :void
  (future fdb-future))

(defcfun "fdb_future_release_memory" :void
  (future fdb-future))

(defcfun "fdb_future_destroy" :void
  (future fdb-future))

(defcfun "fdb_future_block_until_ready" fdb-error-t
  (future fdb-future))

(defcfun "fdb_future_is_ready" fdb-bool-t
  (future fdb-future))

(defctype fdb-callback :pointer)
;(defcallback my-fdb-callback :void ((future fdb-future) (callback-parameter :pointer)))

(defcfun "fdb_future_set_callback" fdb-error-t
  (f fdb-future)
  (callback fdb-callback)
  (callback-parameter :pointer))

(defcfun "fdb_future_get_error" fdb-error-t
  (f fdb-future))

(defcfun "fdb_future_get_version" fdb-error-t
  (f fdb-future)
  (out-version (:pointer :int64)))

(defcfun "fdb_future_get_key" fdb-error-t
  (f fdb-future)
  (out-key (:pointer (:pointer :uint8)))
  (out-key-length (:pointer :int)))

(defcfun "fdb_future_get_cluster" fdb-error-t
  (f fdb-future)
  (out-cluster (:pointer fdb-cluster)))

(defcfun "fdb_future_get_database" fdb-error-t
  (f fdb-future)
  (out-database (:pointer fdb-database)))

(defcfun "fdb_future_get_value" fdb-error-t
  (f fdb-future)
  (out-present (:pointer fdb-bool-t))
  (out-value (:pointer (:pointer :uint8)))
  (out-value-length (:pointer :int)))

(defcfun "fdb_future_get_keyvalue_array" fdb-error-t
  (f fdb-future)
  (out-kv (:pointer (:pointer (:struct fdb-key-value))))
  (out-count (:pointer :int))
  (out-more (:pointer fdb-bool-t)))

(defcfun "fdb_future_get_string_array" fdb-error-t
  (f fdb-future)
  (out-strings (:pointer (:pointer :string)))
  (out-count (:pointer :int)))

(defcfun "fdb_create_cluster" fdb-future
  (cluster-file-path :string))

(defcfun "fdb_cluster_destroy" :void
  (c fdb-cluster))

(defcfun "fdb_cluster_set_option" fdb-error-t
  (c fdb-cluster)
  (option fdb-cluster-option)
  (value (:pointer :uint8))
  (value-length :int))
  
(defcfun "fdb_cluster_create_database" fdb-future
  (c fdb-cluster)
  (db-name (:pointer :uint8))
  (db-name-length :int))

(defcfun "fdb_database_destroy" :void
  (d fdb-database))

(defcfun "fdb_database_set_option" fdb-error-t
  (d fdb-database)
  (option fdb-database-option)
  (value (:pointer :uint8))
  (value-length :int))
  
(defcfun "fdb_database_create_transaction" fdb-error-t
  (d fdb-database)
  (out-transaction (:pointer fdb-transaction)))

(defcfun "fdb_transaction_destroy" :void
  (tr fdb-transaction))

(defcfun "fdb_transaction_cancel" :void
  (tr fdb-transaction))

(defcfun "fdb_transaction_set_option" fdb-error-t
  (tr fdb-transaction)
  (option fdb-transaction-option)
  (value (:pointer :uint8))
  (value-length :int))
  
(defcfun "fdb_transaction_set_read_version" :void
  (tr fdb-transaction)
  (version :int64))

(defcfun "fdb_transaction_get_read_version" fdb-future
  (tr fdb-transaction))

(defcfun "fdb_transaction_get" fdb-future
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int)
  (snapshot fdb-bool-t))

(defcfun "fdb_transaction_get_key" fdb-future
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int)
  (or-equal fdb-bool-t)
  (offset :int)
  (snapshot fdb-bool-t))

(defcfun "fdb_transaction_get_addresses_for_key" fdb-future
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int))

(defcfun "fdb_transaction_get_range" fdb-future
  (tr fdb-transaction)
  (begin-key-name (:pointer :uint8))
  (begin-key-name-length :int)
  (begin-or-equal fdb-bool-t)
  (begin-offset :int)
  (end-key-name (:pointer :uint8))
  (end-key-name-length :int)
  (end-or-equal fdb-bool-t)
  (end-offset :int)
  (limit :int)
  (target-bytes :int)
  (mode fdb-streaming-mode)
  (iteration :int)
  (snapshot fdb-bool-t)
  (reverse fdb-bool-t))

(defcfun "fdb_transaction_set" :void
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int)
  (value-name (:pointer :uint8))
  (value-name-length :int))

(defcfun "fdb_transaction_atomic_op" :void
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int)
  (param (:pointer :uint8))
  (param-length :int)
  (operation-type fdb-mutation-type))

(defcfun "fdb_transaction_clear" :void
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int))

(defcfun "fdb_transaction_clear_range" :void
  (tr fdb-transaction)
  (begin-key-name (:pointer :uint8))
  (begin-key-name-length :int)
  (end-key-name (:pointer :uint8))
  (end-key-name-length :int))

(defcfun "fdb_transaction_watch" fdb-future
  (tr fdb-transaction)
  (key-name (:pointer :uint8))
  (key-name-length :int))

(defcfun "fdb_transaction_commit" fdb-future
  (tr fdb-transaction))

(defcfun "fdb_transaction_get_committed_version" fdb-error-t
  (tr fdb-transaction)
  (out-version (:pointer :int64)))

(defcfun "fdb_transaction_on_error" fdb-future
  (tr fdb-transaction)
  (error fdb-error-t))

(defcfun "fdb_transaction_reset" :void
  (tr fdb-transaction))

(defcfun "fdb_transaction_add_conflict_range" :void
  (tr fdb-transaction)
  (begin-key-name (:pointer :uint8))
  (begin-key-name-length :int)
  (end-key-name (:pointer :uint8))
  (end-key-name-length :int)
  (type fdb-conflict-range-type))

(defcfun "fdb_select_api_version_impl" fdb-error-t
  (runtime-version :int)
  (header-version :int))

(defcfun "fdb_get_max_api_version" :int)
