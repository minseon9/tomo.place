interface RepositoryInterface<T> {
    var entities: ArrayList<T>

//    fun findAllById(id: Int): ArrayList<T> {
//        return ArrayList(entities.filter { it.id == id })
//    }
//
//    fun findById(): T?{
//        return entities.find { it.id == id }
//    }

    fun save(entity: T){
        entities.add(entity)
    }
}