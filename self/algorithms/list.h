struct item {
  struct item *next;
  struct item *prev;
  void *data;
};

struct list {
  struct item *head;
  struct item *tail;
  int length;
};

struct item* get(struct list*, int);
struct item* take(struct list*, int);
struct item* insert(struct list*, struct item*, int);
struct item* pop(struct list*);
struct item* push(struct list*, struct item*);
void each(struct list *listp, void* (*function)(void *));
struct list* map(struct list *listp, void* (*function)(void *));

