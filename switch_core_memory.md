## `switch_core_memory.c`

本章基于Commit Hash `1681db4`。

本文件实现了内存池相关的操作函数，FreeSWITCH的内存池是基于APR的内存池技术。

获取session的内存池（L63），从session的内存池中申请内存（L72），从核心内存池中申请内存。

```c
63  SWITCH_DECLARE(switch_memory_pool_t *) switch_core_session_get_pool(switch_core_session_t *session)

72  SWITCH_DECLARE(void *) switch_core_perform_session_alloc(switch_core_session_t *session, switch_size_t memory, const char *file, const char *func, int line)

108  SWITCH_DECLARE(void *) switch_core_perform_permanent_alloc(switch_size_t memory, const char *file, const char *func, int line)
```

使用核心内存池拷贝字符串（L138），使用session的内存池生成格式化字符串（L175），使用指定内存池生成格式化字符串（L216），使用session的内存池拷贝字符串（L227），使用指定内存池拷贝字符串（L271）。

```c
138  SWITCH_DECLARE(char *) switch_core_perform_permanent_strdup(const char *todup, const char *file, const char *func, int line)

175  SWITCH_DECLARE(char *) switch_core_session_sprintf(switch_core_session_t *session, const char *fmt, ...)

216  SWITCH_DECLARE(char *) switch_core_sprintf(switch_memory_pool_t *pool, const char *fmt, ...)

227  SWITCH_DECLARE(char *) switch_core_perform_session_strdup(switch_core_session_t *session, const char *todup, const char *file, const char *func, int line)

271  SWITCH_DECLARE(char *) switch_core_perform_strdup(switch_memory_pool_t *pool, const char *todup, const char *file, const char *func, int line)
```

给内存池绑定相关联的用户数据（L310）和获取该绑定数据（L315）。

```c
310  SWITCH_DECLARE(void) switch_core_memory_pool_set_data(switch_memory_pool_t *pool, const char *key, void *data)

315  SWITCH_DECLARE(void *) switch_core_memory_pool_get_data(switch_memory_pool_t *pool, const char *key)
```

给内存池打标签。

```c
324  SWITCH_DECLARE(void) switch_core_memory_pool_tag(switch_memory_pool_t *pool, const char *tag)
```

清理内存池中的内存。

```c
329  SWITCH_DECLARE(void) switch_pool_clear(switch_memory_pool_t *p)
```

创建内存池，如果不需要立即创建，则会从可重复使用的内存池队列`memory_manager.pool_recycle_queue`中取出，取出失败才创建新内存池。

```c
352  SWITCH_DECLARE(switch_status_t) switch_core_perform_new_memory_pool(switch_memory_pool_t **pool, const char *file, const char *func, int line)
353  {
...
355  #ifdef INSTANTLY_DESTROY_POOLS
356      apr_pool_create(pool, NULL);
357      switch_assert(*pool != NULL);
358  #else
...
373      if (switch_queue_trypop(memory_manager.pool_recycle_queue, &pop) == SWITCH_STATUS_SUCCESS && pop) {
374          *pool = (switch_memory_pool_t *) pop;
375      } else {
...
397          apr_pool_create(pool, NULL);
...
416  }
```

销毁指定内存池，如果不需要立即销毁则将内存池push到销毁队列，在销毁线程中销毁。

```c
418  SWITCH_DECLARE(switch_status_t) switch_core_perform_destroy_memory_pool(switch_memory_pool_t **pool, const char *file, const char *func, int line)
419  {
...
426  #ifdef INSTANTLY_DESTROY_POOLS
...
434  #else
435      if ((memory_manager.pool_thread_running != 1) || (switch_queue_push(memory_manager.pool_queue, *pool) != SWITCH_STATUS_SUCCESS)) {
...
449 }
```

从指定内存池中申请内存。

```c
451  SWITCH_DECLARE(void *) switch_core_perform_alloc(switch_memory_pool_t *pool, switch_size_t memory, const char *file, const char *func, int line)
```


回收内存池循环队列`memory_manager.pool_recycle_queue`中的内存池。

```c
483  SWITCH_DECLARE(void) switch_core_memory_reclaim(void)
```

内存池销毁线程，销毁内存池队列`memory_manager.pool_queue`中的内存池。

```c
508  static void *SWITCH_THREAD_FUNC pool_thread(switch_thread_t *thread, void *obj)
```

停止内存池销毁线程，销毁内存池队列中的剩余项。

```c
600  void switch_core_memory_stop(void)
```

初始化核心内存池，返回的值将赋值给核心全局变量`runtime.memory_pool`。

```c
618  switch_memory_pool_t *switch_core_memory_init(void)
```
